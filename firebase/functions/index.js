const { onCall, HttpsError } = require('firebase-functions/v2/https');
const { initializeApp } = require('firebase-admin/app');
const { getAuth } = require('firebase-admin/auth');
const { getFirestore, FieldValue } = require('firebase-admin/firestore');

initializeApp();

const db = getFirestore();
const auth = getAuth();

exports.createStaffMember = onCall(async (request) => {
  if (!request.auth) {
    throw new HttpsError('unauthenticated', 'Sign in required.');
  }

  const callerUid = request.auth.uid;
  const callerSnap = await db.collection('users').doc(callerUid).get();
  if (!callerSnap.exists) {
    throw new HttpsError('permission-denied', 'Caller profile not found.');
  }

  const caller = callerSnap.data();
  const callerRole = caller.role || '';
  const canManage =
    callerRole === 'owner' ||
    (callerRole === 'manager' && caller.permissions?.canManageUsers === true);

  if (!canManage) {
    throw new HttpsError('permission-denied', 'Only owners can add team members.');
  }

  const {
    email,
    password,
    displayName,
    role,
    permissions = {},
  } = request.data || {};

  if (!email || !password || !displayName || !role) {
    throw new HttpsError('invalid-argument', 'email, password, displayName, and role are required.');
  }

  if (password.length < 6) {
    throw new HttpsError('invalid-argument', 'Password must be at least 6 characters.');
  }

  const allowedRoles = ['manager', 'cashier', 'stockManager', 'accountant'];
  if (!allowedRoles.includes(role)) {
    throw new HttpsError('invalid-argument', 'Invalid role for new staff.');
  }

  const storeId = caller.storeId;
  if (!storeId) {
    throw new HttpsError('failed-precondition', 'Store not configured for caller.');
  }

  let userRecord;
  try {
    userRecord = await auth.createUser({
      email: String(email).trim().toLowerCase(),
      password: String(password),
      displayName: String(displayName).trim(),
    });
  } catch (e) {
    if (e.code === 'auth/email-already-exists') {
      throw new HttpsError('already-exists', 'An account with this email already exists.');
    }
    throw new HttpsError('internal', e.message || 'Could not create auth user.');
  }

  const permMap = {};
  if (permissions && typeof permissions === 'object') {
    for (const [key, value] of Object.entries(permissions)) {
      if (value === true) permMap[key] = true;
    }
  }

  try {
    await db.collection('users').doc(userRecord.uid).set({
      email: userRecord.email,
      displayName: String(displayName).trim(),
      storeId,
      role,
      permissions: permMap,
      isActive: true,
      createdAt: FieldValue.serverTimestamp(),
      updatedAt: FieldValue.serverTimestamp(),
      createdBy: callerUid,
      updatedBy: callerUid,
    });
  } catch (e) {
    await auth.deleteUser(userRecord.uid).catch(() => {});
    throw new HttpsError('internal', 'Could not create user profile.');
  }

  return { uid: userRecord.uid, email: userRecord.email };
});

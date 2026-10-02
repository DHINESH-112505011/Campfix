const request = require('supertest');

// We can't easily import app.js directly since server.js calls app.listen()
// immediately. Instead we hit the already-running dev server. This means
// `npm run dev` must be running in another terminal before this test runs.
const BASE_URL = process.env.TEST_API_URL || 'http://localhost:5000';

const { getAuthToken } = require('./testHelpers');

const TEST_STUDENT = { email: 'test-student@campfix.test', password: 'TestPassword123!' };
const TEST_STAFF = { email: 'test-staff@campfix.test', password: 'TestPassword123!' };
const TEST_ADMIN = { email: 'test-admin@campfix.test', password: 'TestPassword123!' };

let studentToken, staffToken, adminToken;
let studentComplaintId;

beforeAll(async () => {
  studentToken = await getAuthToken(TEST_STUDENT.email, TEST_STUDENT.password);
  staffToken = await getAuthToken(TEST_STAFF.email, TEST_STAFF.password);
  adminToken = await getAuthToken(TEST_ADMIN.email, TEST_ADMIN.password);
}, 20000);

describe('Authentication requirements', () => {
  test('rejects requests with no auth token', async () => {
    const res = await request(BASE_URL).get('/api/complaints');
    expect(res.status).toBe(401);
    expect(res.body.success).toBe(false);
  });

  test('rejects requests with an invalid/garbage token', async () => {
    const res = await request(BASE_URL)
      .get('/api/complaints')
      .set('Authorization', 'Bearer not-a-real-token');
    expect(res.status).toBe(401);
  });
});

describe('Student complaint creation and ownership', () => {
  test('student can create a complaint', async () => {
    const res = await request(BASE_URL)
      .post('/api/complaints')
      .set('Authorization', `Bearer ${studentToken}`)
      .send({
        title: 'Test complaint from automated suite',
        description: 'This is a test complaint created by the Jest test suite.',
        building: 'Test Block',
        room: 'Test Room 1',
      });

    expect(res.status).toBe(201);
    expect(res.body.success).toBe(true);
    expect(res.body.data.complaint_number).toMatch(/^CF-\d{4}-\d{5}$/);
    studentComplaintId = res.body.data.id;
  });

  test('student can view their own complaint', async () => {
    const res = await request(BASE_URL)
      .get(`/api/complaints/${studentComplaintId}`)
      .set('Authorization', `Bearer ${studentToken}`);
    expect(res.status).toBe(200);
    expect(res.body.data.id).toBe(studentComplaintId);
  });
});

describe('Role isolation (§81 critical security tests)', () => {
  test('student cannot call admin-only staff assignment endpoint', async () => {
    const res = await request(BASE_URL)
      .get('/api/staff/available')
      .set('Authorization', `Bearer ${studentToken}`);
    expect(res.status).toBe(403);
  });

  test('student cannot call admin-only dashboard endpoint', async () => {
    const res = await request(BASE_URL)
      .get('/api/dashboard/admin')
      .set('Authorization', `Bearer ${studentToken}`);
    expect(res.status).toBe(403);
  });

  test('staff cannot call admin-only assign endpoint', async () => {
    const res = await request(BASE_URL)
      .post('/api/assignments/assign')
      .set('Authorization', `Bearer ${staffToken}`)
      .send({ complaintId: studentComplaintId, staffId: 'fake-id' });
    expect(res.status).toBe(403);
  });

  test('student cannot directly set complaint to RESOLVED (blocked by transition rules)', async () => {
    // From SUBMITTED, RESOLVED isn't even a structurally valid next step,
    // so this is correctly rejected as an invalid transition (400) before
    // role-based authorization is even evaluated. Either way, the student
    // can never force a complaint to RESOLVED - that's the property we
    // actually care about here.
    const res = await request(BASE_URL)
      .patch(`/api/complaints/${studentComplaintId}/status`)
      .set('Authorization', `Bearer ${studentToken}`)
      .send({ status: 'RESOLVED' });
    expect([400, 403]).toContain(res.status);
    expect(res.body.success).toBe(false);
  });

  test('student cannot set a role-forbidden but structurally valid status (ADMIN_REVIEW)', async () => {
    // ADMIN_REVIEW is a VALID transition from SUBMITTED, but students are
    // not allowed to set it directly - this isolates the role-check itself.
    const res = await request(BASE_URL)
      .patch(`/api/complaints/${studentComplaintId}/status`)
      .set('Authorization', `Bearer ${studentToken}`)
      .send({ status: 'ADMIN_REVIEW' });
    expect(res.status).toBe(403);
  });

  test('student CAN cancel their own complaint', async () => {
    const res = await request(BASE_URL)
      .patch(`/api/complaints/${studentComplaintId}/status`)
      .set('Authorization', `Bearer ${studentToken}`)
      .send({ status: 'CANCELLED' });
    expect(res.status).toBe(200);
    expect(res.body.data.status).toBe('CANCELLED');
  });

  test('regular admin cannot access super-admin-only audit logs', async () => {
    const res = await request(BASE_URL)
      .get('/api/audit-logs')
      .set('Authorization', `Bearer ${adminToken}`);
    expect(res.status).toBe(403);
  });
});

describe('Invalid input handling', () => {
  test('rejects complaint creation with missing required fields', async () => {
    const res = await request(BASE_URL)
      .post('/api/complaints')
      .set('Authorization', `Bearer ${studentToken}`)
      .send({ title: 'ab' }); // too short, missing fields
    expect(res.status).toBe(400);
    expect(res.body.error.code).toBe('VALIDATION_ERROR');
  });

  test('rejects an invalid complaint ID format gracefully (no raw DB error leaked)', async () => {
    const res = await request(BASE_URL)
      .get('/api/complaints/not-a-valid-uuid')
      .set('Authorization', `Bearer ${studentToken}`);
    expect(res.status).toBeGreaterThanOrEqual(400);
    // §95 - never leak raw Postgres/Supabase error text
    expect(res.body.message).not.toMatch(/postgres|supabase|syntax error/i);
  });
});
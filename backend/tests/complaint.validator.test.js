const { validateCreateComplaint, validateStatusTransition } = require('../src/validators/complaint.validator');

describe('validateCreateComplaint', () => {
  test('rejects missing title', () => {
    const errors = validateCreateComplaint({
      description: 'Something is broken here',
      building: 'Main Block',
      room: '101',
    });
    expect(errors).toContain('Title must be at least 3 characters.');
  });

  test('rejects short description', () => {
    const errors = validateCreateComplaint({
      title: 'Fan broken',
      description: 'no',
      building: 'Main Block',
      room: '101',
    });
    expect(errors.length).toBeGreaterThan(0);
  });

  test('rejects missing building', () => {
    const errors = validateCreateComplaint({
      title: 'Fan broken',
      description: 'Fan is not working',
      room: '101',
    });
    expect(errors).toContain('Building is required.');
  });

  test('accepts valid complaint data', () => {
    const errors = validateCreateComplaint({
      title: 'Fan broken',
      description: 'Fan is not working in my room',
      building: 'Main Block',
      room: '101',
    });
    expect(errors).toEqual([]);
  });

  test('rejects invalid priority value', () => {
    const errors = validateCreateComplaint({
      title: 'Fan broken',
      description: 'Fan is not working in my room',
      building: 'Main Block',
      room: '101',
      priority: 'SUPER_URGENT',
    });
    expect(errors).toContain('Invalid priority value.');
  });
});

describe('validateStatusTransition', () => {
  test('allows SUBMITTED -> ADMIN_REVIEW', () => {
    expect(validateStatusTransition('SUBMITTED', 'ADMIN_REVIEW')).toBeNull();
  });

  test('allows ADMIN_REVIEW -> ASSIGNED', () => {
    expect(validateStatusTransition('ADMIN_REVIEW', 'ASSIGNED')).toBeNull();
  });

  test('rejects SUBMITTED -> RESOLVED (skipping the whole workflow)', () => {
    const error = validateStatusTransition('SUBMITTED', 'RESOLVED');
    expect(error).not.toBeNull();
  });

  test('rejects transitions from a terminal state (REJECTED)', () => {
    const error = validateStatusTransition('REJECTED', 'ASSIGNED');
    expect(error).not.toBeNull();
  });

  test('rejects an unknown status value entirely', () => {
    const error = validateStatusTransition('SUBMITTED', 'MADE_UP_STATUS');
    expect(error).toContain('is not a valid status');
  });

  test('allows RESOLVED -> REOPENED (student reopen flow)', () => {
    expect(validateStatusTransition('RESOLVED', 'REOPENED')).toBeNull();
  });
});
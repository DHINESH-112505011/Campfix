const AI_SERVICE_URL = process.env.AI_SERVICE_URL || 'http://localhost:5001';

/**
 * Calls the Python AI microservice to classify a complaint's text.
 * Fails gracefully - if the AI service is down, the complaint still
 * gets created (AI is advisory per §91, never a hard blocker).
 */
async function classifyComplaint(text) {
  try {
    const response = await fetch(`${AI_SERVICE_URL}/predict`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ text }),
      signal: AbortSignal.timeout(5000),
    });

    if (!response.ok) {
      throw new Error(`AI service returned ${response.status}`);
    }

    const data = await response.json();
    return {
      category: data.category || null,
      priority: data.priority || null,
      confidence: data.confidence || null,
    };
  } catch (err) {
    console.error('[AI SERVICE] Classification failed, continuing without AI data:', err.message);
    return { category: null, priority: null, confidence: null };
  }
}

module.exports = { classifyComplaint };
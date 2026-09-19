const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const rateLimit = require('express-rate-limit');

const env = require('./src/config/env');
const requestLogger = require('./src/middleware/requestLogger');
const { errorHandler, notFoundHandler } = require('./src/middleware/errorHandler');
const apiRoutes = require('./src/routes');

const app = express();

app.use(helmet());
app.use(cors());
app.use(express.json({ limit: '2mb' }));
app.use(requestLogger);

const limiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 300,
  standardHeaders: true,
  legacyHeaders: false,
});
app.use(limiter);

app.use('/api', apiRoutes);

app.use(notFoundHandler);
app.use(errorHandler);

app.listen(env.port, () => {
  console.log(`CampFix backend running on http://localhost:${env.port} [${env.nodeEnv}]`);
});
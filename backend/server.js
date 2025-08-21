import express from "express";
import cors from "cors";
import helmet from "helmet";
import morgan from "morgan";
import dotenv from "dotenv";
import rateLimit from "express-rate-limit";
import mongoose from "mongoose";
import feedbackRouter from "./src/routes/feedbacks.js";
import enquiryRouter from "./src/routes/enquiries.js";
import businessRouter from "./src/routes/businesses.js";

dotenv.config();
const app = express();

// CORS: treat "*" as real wildcard, otherwise split by comma
const raw = process.env.CORS_ORIGIN?.trim();
const allowedOrigins = !raw || raw === "*" ? "*" : raw.split(",").map((s) => s.trim());

app.use(
  cors({
    origin: allowedOrigins, // "*" OR ["http://localhost:xxxxx", ...]
    methods: ["GET", "POST", "OPTIONS"],
    allowedHeaders: ["Content-Type"],
    credentials: false,
  })
);
// Handle preflight for all routes
app.options("*", cors());

app.use(helmet());
app.use(express.json());
app.use(morgan("tiny"));

const limiter = rateLimit({ windowMs: 60_000, max: 60 });
app.use("/api/", limiter);

app.get("/api/health", (_req, res) => res.json({ ok: true }));

app.use("/api/feedbacks", feedbackRouter);
app.use("/api/enquiries", enquiryRouter);
app.use("/api/businesses", businessRouter);

const PORT = process.env.PORT || 8080;
const MONGO = process.env.MONGODB_URI;

mongoose
  .connect(MONGO, { dbName: process.env.MONGODB_DB || "e_visiting_card" })
  .then(() => {
    app.listen(PORT, () =>
      console.log(`API running on :${PORT} (Mongo connected)`)
    );
  })
  .catch((e) => {
    console.error("Mongo connection failed", e);
    process.exit(1);
  });
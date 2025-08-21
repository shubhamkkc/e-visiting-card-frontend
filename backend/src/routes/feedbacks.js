import { Router } from "express";
import Feedback from "../models/Feedback.js";

const router = Router();

// GET /api/feedbacks
router.get("/", async (_req, res) => {
  const list = await Feedback.find().sort({ createdAt: -1 }).limit(200);
  res.json(list);
});

// POST /api/feedbacks
router.post("/", async (req, res) => {
  const { name, rating, comment } = req.body || {};
  if (!name || !rating || !comment) {
    return res.status(400).json({ error: "name, rating, comment required" });
  }
  const fb = await Feedback.create({ name, rating, comment });
  res.status(201).json(fb);
});

export default router;
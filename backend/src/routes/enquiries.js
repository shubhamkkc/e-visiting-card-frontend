import { Router } from "express";
import Enquiry from "../models/Enquiry.js";

const router = Router();

// POST /api/enquiries
router.post("/", async (req, res) => {
  const { name, phone, email, message } = req.body || {};
  if (!name || !phone || !message) {
    return res
      .status(400)
      .json({ error: "name, phone, message are required" });
  }
  const enq = await Enquiry.create({ name, phone, email, message });
  res.status(201).json(enq);
});

export default router;
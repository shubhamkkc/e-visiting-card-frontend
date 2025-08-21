import { Router } from "express";
import Business from "../models/Business.js";

const router = Router();

// GET /api/businesses/:slug
router.get("/:slug", async (req, res) => {
  const biz = await Business.findOne({ slug: req.params.slug });
  if (!biz) return res.status(404).json({ error: "Business not found" });
  res.json(biz);
});

// GET /api/businesses/:slug/views -> { views }
router.get("/:slug/views", async (req, res) => {
  const biz = await Business.findOne({ slug: req.params.slug }).select("views");
  if (!biz) return res.status(404).json({ error: "Business not found" });
  res.json({ views: biz.views ?? 0 });
});

// POST /api/businesses/:slug/views/increment -> { views }
router.post("/:slug/views/increment", async (req, res) => {
  const updated = await Business.findOneAndUpdate(
    { slug: req.params.slug },
    { $inc: { views: 1 } },
    { new: true, projection: { views: 1 } }
  );
  if (!updated) return res.status(404).json({ error: "Business not found" });
  res.json({ views: updated.views ?? 0 });
});

export default router;
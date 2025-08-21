import mongoose from "mongoose";

const FeedbackSchema = new mongoose.Schema(
  {
    name: { type: String, required: true, trim: true },
    rating: { type: Number, min: 1, max: 5, required: true },
    comment: { type: String, required: true, trim: true }
  },
  { timestamps: true }
);

export default mongoose.model("Feedback", FeedbackSchema);
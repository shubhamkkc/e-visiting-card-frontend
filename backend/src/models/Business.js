import mongoose from "mongoose";

const ProductSchema = new mongoose.Schema(
  { name: String, image: String },
  { _id: false }
);

const BusinessSchema = new mongoose.Schema(
  {
    slug: { type: String, unique: true, index: true },
    businessName: String,
    tagline: String,
    ownerName: String,
    establishedYear: String,
    address: String,
    email: String,
    phone1: String,
    phone2: String,
    whatsappNumber: String,
    natureOfBusiness: String,
    aboutUs: String,
    googleMapLink: String,
    vCardDownloadLink: String,
    profileUrl: String,
    specialities: String,
    products: [ProductSchema],
    galleryImages: [String],
    theme: {
      primaryColor: { type: String, default: "#FF6A00" }
    },
    views: { type: Number, default: 0 },
    logoUrl: { type: String, default: "" } // <— added
  },
  { timestamps: true }
);

export default mongoose.model("Business", BusinessSchema);
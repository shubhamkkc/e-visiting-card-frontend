import dotenv from "dotenv";
import mongoose from "mongoose";
import Business from "../models/Business.js";

dotenv.config();

async function main() {
  await mongoose.connect(process.env.MONGODB_URI, {
    dbName: process.env.MONGODB_DB || "e_visiting_card",
  });

  const doc = {
    // identify the business to upsert
    slug: "kanhaiya-lal-sons",
    // ...existing fields...
    businessName: "Kanhaiya Lal & Sons",
    tagline: "Turning Up the Sound of Bihar",
    ownerName: "Kumar Krishna",
    establishedYear: "1992",
    address:
      "Near Electronics Market, Baker Gunj Gola Road, Bakerganj, Patna – 800004, Bihar, India",
    email: "djwallaah@gmail.com",
    phone1: "+91 7004737505",
    phone2: "+91 6204123526",
    whatsappNumber: "+91 7004737505",
    natureOfBusiness: "Audio speaker dealer • DJ & sound system equipment",
    aboutUs:
      "One of Patna's premier DJ and audio equipment shops offering speakers, sound boxes, PA systems, amplifiers, mixers and more.",
    googleMapLink: "https://maps.app.goo.gl/9CBKhaw9Wy8nNR6W9",
    vCardDownloadLink: "",
    profileUrl: "",
    specialities: `• Manufacturing custom DJ sound boxes
• Selling a wide range of DJ items & equipment
• Professional sales and after-sales service
• Quality products at affordable prices
• Trusted name in sound systems in Patna`,

    // Use HTTPS image URLs (examples use placehold.co; replace with your CDN/Cloudinary URLs)
    products: [
      { name: "Amplifier",  image: "https://storage.googleapis.com/stateless-blog-g4m-co-uk/2023/08/Power-Amps-768x384.jpg" },
      { name: "Speaker",    image: "https://5.imimg.com/data5/SELLER/Default/2024/1/381752074/ET/GQ/AH/64771143/18inch-audio-x-tbw-100-1500w-pro-speaker.jpg" },
      { name: "Sound Box",  image: "https://www.rcf.it/documents/20128/1136109/Vmax-Series.png/ea5c637b-095a-ffbc-f0e3-eeb9a22c1209?version=2.0&t=1663933442637&imagePreview=1" },
      { name: "Horn",       image: "https://5.imimg.com/data5/CS/SI/HT/SELLER-12861571/aluminum-loud-speaker-trumpet-horn-500x500.jpg" },
      { name: "Microphone", image: "https://www.shutterstock.com/image-photo/microphone-on-stage-live-showbiz-600nw-2524803527.jpg" },
      { name: "DJ Lights",  image: "https://5.imimg.com/data5/SELLER/Default/2024/2/389095479/QF/AI/ZL/5488523/dj-sharpy-light.jpg" },
    ],

    galleryImages: [
      "https://lh3.googleusercontent.com/geougc-cs/AB3l90DJPCfZK7WLlGnVYnkpiaye4MpkT3ITSp6naVBnbBldblCetGIsxcgTRbXFbD0iBzj0WKq75lfTTSoDD0R-ZTlqO4FOncznj3Wxur61ngIiYnjTGJKsav2f6ML_5Qt1_ZXKSsx9EA=s2732-w2732-h1214-rw",
      "https://lh3.googleusercontent.com/geougc-cs/AB3l90Avw0DtfKN2APe5OCNRNM2-ZZ2V72ClLidn-Eq34r4Omo1S8NhMmpoSmSbUxOZ0iPbJL-pZ5TZBqbBG6qqdtc2Z_yPeMGAqGJoxTJeWdW7Wn5sYMipJMpX3DtGu-Q-6-bwnq1E=s2732-w2732-h1214-rw",
      "https://lh3.googleusercontent.com/geougc-cs/AB3l90CXDyVIY7cUjaA8DHSI2Rw6J6DY9dDZm4HSZrU1hbVPgT9rGzE5vLRq6txSOzLwBg0kgcOWthrvYMRUylzoNjOMrMdctUJiIgm4r0yxo75AVQR5B_4zI6YiUUprLx3RqXnLf8hg=s2732-w2732-h1214-rw",
      "https://lh3.googleusercontent.com/geougc-cs/AB3l90AEHZ1Zk-we6tFe8iqDhRMt9vnTfg8jxXGeAyijqliNw0bjVi5efX_VoMLaguMq_nq_lJ4wxU7hu_809pZdforwLwv3yWDtctfnBZtGMtvXUrBJzH2G2bWAzknEwvgepRdNAARl-ZCaWgk=s2732-w2732-h1214-rw",
    ],

    theme: { primaryColor: "#FF3B30" },

    // NEW: set your public logo URL (HTTPS)
    logoUrl: "https://chatgpt.com/backend-api/public_content/enc/eyJpZCI6Im1fNjhhNzViOTBhNTJjODE5MTkzZDc0NWI1ZGE5ODg0ZWM6ZmlsZV8wMDAwMDAwMGY4YzA2MjMwYjU4ODMzY2JkZDExNGRhMSIsInRzIjoiNDg3NzIyIiwicCI6InB5aSIsInNpZyI6IjY0MWI0NDY5ZDk5OGM1NjY3NmUxODA2MWFiYjJlMGQ3MWM5MTg2NTEwYzU1ZjBhMmIzYmVhZmQwNDEzNDQwYjgiLCJ2IjoiMCIsImdpem1vX2lkIjpudWxsfQ==",
    // tip: replace with your real CDN/Cloudinary/S3 URL
  };

  await Business.findOneAndUpdate({ slug: doc.slug }, doc, {
    upsert: true,
    new: true,
    setDefaultsOnInsert: true,
  });

  console.log("Seeded:", doc.slug);
  await mongoose.disconnect();
}

main().catch((e) => {
  console.error(e);
  process.exit(1);
});
// import React from "react";

// function page() {
//   return <div className="text-white text-2xl">hello this is dashboard</div>;
// }

// export default page;
"use client";

import { SplashCursor } from "@/components/ui/splash-cursor";
import { TextRotate } from "@/components/ui/text-rotate";
import { LayoutGroup, motion } from "motion/react";
import Link from "next/link";

function Page() {
  const cardNames = [
    "Code",
    "Documents",
    "Everyday Utilities",
    "Work",
    "Network",
    "Security",
  ];

  return (
    <div className="relative min-h-screen bg-black overflow-hidden flex flex-col items-center justify-center gap-12 px-4 py-10">
      {/* Animated Background */}
      <div className="absolute inset-0 z-0">
        <SplashCursor />
      </div>

      {/* Animated Text */}
      <div className="relative z-10 text-2xl sm:text-3xl md:text-5xl font-overusedGrotesk text-white font-light overflow-hidden">
        <LayoutGroup>
          <motion.div className="flex whitespace-pre" layout>
            <motion.span
              className="pt-0.5 sm:pt-1 md:pt-2"
              layout
              transition={{ type: "spring", damping: 30, stiffness: 400 }}
            ></motion.span>
            <TextRotate
              texts={[
                "Welcome to",
                "Bienvenue à",
                "Bienvenido a",
                "Benvenuto a",
                "ようこそ〜へ",
              ]}
              mainClassName="text-white justify-center rounded-lg"
              staggerFrom={"last"}
              initial={{ y: "100%" }}
              animate={{ y: 0 }}
              exit={{ y: "-120%" }}
              staggerDuration={0.025}
              splitLevelClassName="overflow-hidden pb-0.5 sm:pb-1 md:pb-1"
              transition={{ type: "spring", damping: 30, stiffness: 400 }}
              rotationInterval={2000}
            />
            <span className="ml-[12px]">Utilify!</span>
          </motion.div>
        </LayoutGroup>
      </div>

      {/* Cards Grid */}
      <div className="relative z-10 grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-x-4 gap-y-4">
        {cardNames.map((name, i) => (
          <Link
            href={
              name === "Code"
                ? "/code/compiler"
                : name === "Documents"
                ? "/documents/excelcsv"
                : name === "Everyday Utilities"
                ? "/everyday/color-pallete"
                : name === "Work"
                ? "/work/qrgenerator"
                : name === "Network"
                ? "/network"
                : "/security"
            }
            key={i}
          >
            <div className="relative h-44 w-64">
              {/* Optional GlowEffect */}
              {/* <GlowEffect
              colors={['#0894FF', '#C959DD', '#FF2E54', '#FF9004']}
              mode="static"
              blur="strong"
              /> */}
              <div className="relative h-44 w-64 rounded-xl bg-gray/80 text-white p-4 flex items-center justify-center shadow-lg backdrop-blur">
                {name}
              </div>
            </div>
          </Link>
        ))}
      </div>
    </div>
  );
}

export default Page;

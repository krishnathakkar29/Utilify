'use client'
import Link from "next/link";
import { Card } from "@/components/landing-card";
import { SplineScene } from "@/components/ui/splite";
import { Spotlight } from "@/components/ui/spotlight";
import AnimatedWordCycle from "@/components/ui/animated-text-cycle"

export default function Page() {
  return (
    <Card className="w-full h-screen bg-black/[0.96] relative overflow-hidden">
      <Spotlight className="-top-40 left-0 md:left-60 md:-top-20" />

      <div className="flex h-full">
        {/* Left content */}
        <div className="flex-1 p-8 relative z-10 flex flex-col justify-center">
          <h1 className="text-6xl md:text-7xl font-bold bg-clip-text text-transparent bg-gradient-to-b from-neutral-50 to-neutral-400">
            Utilify
          </h1>

          <div className="mt-4 text-xl md:text-3xl text-neutral-400 max-w-lg">
            Your <AnimatedWordCycle 
              words={[
                "codes",
                "business",
                "team",
                "workflow",
                "productivity",
                "projects",
                "analytics",
              ]}
              interval={3000}
              className={"text-foreground font-semi-bold"} 
            /> deserves better tools
          </div>

          {/* Get Started Button */}
          <Link href="/dashboard">
            <button className="mt-6 w-fit px-5 py-2 text-sm font-medium bg-white text-black rounded-md hover:bg-neutral-200 transition">
              Get Started
            </button>
          </Link>
        </div>

        {/* Right content */}
        <div className="flex-1 relative">
          <SplineScene 
            scene="https://prod.spline.design/kZDDjO5HuC9GJUM2/scene.splinecode"
            className="w-full h-full"
          />
        </div>
      </div>
    </Card>
  );
}

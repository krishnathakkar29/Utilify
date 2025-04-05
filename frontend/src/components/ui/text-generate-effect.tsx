"use client";
import { useEffect, useState } from "react";
import { motion } from "framer-motion";
import { cn } from "@/lib/utils";

export const TextGenerateEffect = ({
  words,
  className,
}: {
  words: string;
  className?: string;
}) => {
  const [completedTyping, setCompletedTyping] = useState(false);
  const [currentText, setCurrentText] = useState("");

  useEffect(() => {
    let timeout: NodeJS.Timeout;
    if (currentText.length < words.length) {
      timeout = setTimeout(() => {
        setCurrentText(words.slice(0, currentText.length + 1));
      }, 20);
    } else if (!completedTyping) {
      setCompletedTyping(true);
    }
    return () => clearTimeout(timeout);
  }, [currentText, words, completedTyping]);

  return (
    <h2 className={cn("font-bold", className)}>
      {currentText}
      {!completedTyping && (
        <motion.span
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          transition={{
            duration: 0.1,
            repeat: Infinity,
            repeatType: "reverse",
          }}
          className="inline-block ml-1 h-4 w-[1px] bg-current"
        ></motion.span>
      )}
    </h2>
  );
};

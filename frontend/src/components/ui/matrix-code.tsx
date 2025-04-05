import React, { useEffect, useRef } from 'react';

interface MatrixRainProps {
  fontSize?: number;
  color?: string;
  characters?: string;
  fadeOpacity?: number;
  speed?: number;
}

const MatrixRain: React.FC<MatrixRainProps> = ({
  fontSize = 20,
  color = '#00ff00',
  characters = '01',
  fadeOpacity = 0.1,
  speed = 1,
}) => {
  const canvasRef = useRef<HTMLCanvasElement>(null);

  useEffect(() => {
    const canvas = canvasRef.current;
    if (!canvas) return;

    const ctx = canvas.getContext('2d');
    if (!ctx) return;

    // const getSidebarWidth = () => {
    //   // Try to find the sidebar using a predictable class or structure
    //   const sidebar = document.querySelector('aside'); // You can also try: '.sidebar', '[role="complementary"]', etc.
    //   return sidebar instanceof HTMLElement ? sidebar.offsetWidth : 0;
    // };

    const resizeCanvas = () => {
      const sidebarWidth = 260;

      canvas.width = window.innerWidth - sidebarWidth;
      canvas.height = window.innerHeight;
      canvas.style.left = `${sidebarWidth}px`;
    };

    resizeCanvas();
    window.addEventListener('resize', resizeCanvas);

    const chars = characters.split('');
    let drops: number[] = [];

    const draw = () => {
      ctx.fillStyle = `rgba(0, 0, 0, ${fadeOpacity})`;
      ctx.fillRect(0, 0, canvas.width, canvas.height);

      ctx.fillStyle = color;
      ctx.font = `${fontSize}px monospace`;

      const columnCount = Math.floor(canvas.width / fontSize);
      if (drops.length !== columnCount) {
        drops = Array(columnCount).fill(0).map(() => Math.random() * -100);
      }

      for (let i = 0; i < drops.length; i++) {
        const char = chars[Math.floor(Math.random() * chars.length)];
        ctx.fillText(char, i * fontSize, drops[i] * fontSize);

        if (drops[i] * fontSize > canvas.height && Math.random() > 0.975) {
          drops[i] = 0;
        }
        drops[i] += speed;
      }
    };

    const interval = setInterval(draw, 33 / speed);

    return () => {
      clearInterval(interval);
      window.removeEventListener('resize', resizeCanvas);
    };
  }, [fontSize, color, characters, fadeOpacity, speed]);

  return (
    <canvas
      ref={canvasRef}
      style={{
        position: 'fixed',
        top: 0,
        left: 0,
        marginTop: "4rem",
        height: 'calc(100% - 4rem)',
        width: "100%",
        zIndex: 0,
        pointerEvents: 'none',
      }}
    />
  );
};

export default MatrixRain;

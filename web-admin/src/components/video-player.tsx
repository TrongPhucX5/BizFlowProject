"use client";

import React, { useEffect, useRef, useState } from "react";

interface VideoPlayerProps {
  src: string;
  poster?: string;
  className?: string;
  controls?: boolean;
  autoPlay?: boolean;
  muted?: boolean;
  loop?: boolean;
  preload?: "none" | "metadata" | "auto";
}

export default function VideoPlayer({
  src,
  poster,
  className = "",
  controls = false,
  autoPlay = false,
  muted = false,
  loop = false,
  preload = "metadata",
}: VideoPlayerProps) {
  const containerRef = useRef<HTMLDivElement | null>(null);
  const videoRef = useRef<HTMLVideoElement | null>(null);
  const [isLoaded, setIsLoaded] = useState(false);
  const [isPlaying, setIsPlaying] = useState(false);
  const [isVisible, setIsVisible] = useState(false);

  useEffect(() => {
    if (isLoaded) return;
    if (typeof IntersectionObserver === "undefined") {
      // If no IntersectionObserver support, load immediately
      setIsVisible(true);
      return;
    }

    const el = containerRef.current;
    if (!el) return;

    const obs = new IntersectionObserver(
      (entries) => {
        entries.forEach((entry) => {
          if (entry.isIntersecting) {
            setIsVisible(true);
            obs.disconnect();
          }
        });
      },
      { root: null, threshold: 0.1 }
    );

    obs.observe(el);
    return () => obs.disconnect();
  }, [isLoaded]);

  useEffect(() => {
    if (isLoaded && autoPlay && videoRef.current) {
      // try to play (muted autoplay typically allowed)
      videoRef.current.play().catch(() => {
        /* ignore */
      });
    }
  }, [isLoaded, autoPlay]);

  const handleStart = () => {
    setIsLoaded(true);
    setTimeout(() => {
      if (videoRef.current) {
        videoRef.current.play().catch(() => {});
        setIsPlaying(true);
      }
    }, 20);
  };

  return (
    <div ref={containerRef} className={`relative ${className}`}>
      {!isLoaded && (
        <div
          className={`relative w-full h-full bg-black rounded-lg overflow-hidden flex items-center justify-center`}
          style={{ backgroundImage: poster ? `url(${poster})` : undefined, backgroundSize: "cover", backgroundPosition: "center" }}
        >
          {!isVisible ? (
            // Placeholder until in viewport
            <div className="w-full h-full opacity-0" />
          ) : (
            <button
              aria-label="Play video"
              type="button"
              onClick={handleStart}
              className="flex items-center justify-center w-16 h-16 bg-white/10 rounded-full backdrop-blur hover:bg-white/20"
            >
              <svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
                <path d="M8 5v14l11-7L8 5z" fill="white" />
              </svg>
            </button>
          )}
        </div>
      )}

      {isLoaded && (
        <video
          ref={videoRef}
          src={src}
          poster={poster}
          className="w-full h-full object-cover rounded-lg"
          controls={controls}
          autoPlay={autoPlay}
          muted={muted}
          loop={loop}
          playsInline
          preload={preload}
        >
          Trình duyệt của bạn không hỗ trợ thẻ video.
        </video>
      )}
    </div>
  );
}

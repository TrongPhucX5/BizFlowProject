"use client";

import React, { useEffect, useRef } from "react";

interface VideoNoFullscreenProps {
  src: string;
  poster?: string;
  className?: string;
  autoPlay?: boolean;
  muted?: boolean;
  loop?: boolean;
  preload?: "none" | "metadata" | "auto";
}

export default function VideoNoFullscreen({
  src,
  poster,
  className = "",
  autoPlay = false,
  muted = false,
  loop = false,
  preload = "metadata",
}: VideoNoFullscreenProps) {
  const ref = useRef<HTMLVideoElement | null>(null);

  useEffect(() => {
    const el = ref.current;
    if (!el) return;

    // Prevent double-click toggling fullscreen
    const dbl = (e: MouseEvent) => {
      e.preventDefault();
      e.stopPropagation();
    };

    // Prevent context menu (optional)
    const ctx = (e: Event) => {
      // allow user to right-click if needed; comment out to enable prevention
      // e.preventDefault();
    };

    el.addEventListener("dblclick", dbl);
    el.addEventListener("contextmenu", ctx);

    return () => {
      el.removeEventListener("dblclick", dbl);
      el.removeEventListener("contextmenu", ctx);
    };
  }, []);

  // Toggle play/pause on single click
  const handleClick = () => {
    const v = ref.current;
    if (!v) return;
    if (v.paused) v.play().catch(() => {});
    else v.pause();
  };

  return (
    <video
      ref={ref}
      src={src}
      poster={poster}
      className={`${className} object-cover rounded-lg`}
      onClick={handleClick}
      autoPlay={autoPlay}
      muted={muted}
      loop={loop}
      playsInline
      preload={preload}
      // Prevent picture-in-picture and controls fullscreen
      disablePictureInPicture
      // controlsList supported in modern browsers
      controlsList="nofullscreen nodownload noremoteplayback"
    >
      Trình duyệt của bạn không hỗ trợ thẻ video.
    </video>
  );
}

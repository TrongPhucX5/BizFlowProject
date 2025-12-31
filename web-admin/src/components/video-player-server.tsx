import React from "react";

interface VideoPlayerServerProps {
  src: string;
  poster?: string;
  className?: string;
  controls?: boolean;
  autoPlay?: boolean;
  muted?: boolean;
  loop?: boolean;
  preload?: "none" | "metadata" | "auto";
}

export default function VideoPlayerServer({
  src,
  poster,
  className = "",
  controls = true,
  autoPlay = false,
  muted = false,
  loop = false,
  preload = "metadata",
}: VideoPlayerServerProps) {
  return (
    <video
      src={src}
      poster={poster}
      className={`${className} object-cover rounded-lg`}
      controls={controls}
      autoPlay={autoPlay}
      muted={muted}
      loop={loop}
      playsInline
      preload={preload}
      // Disable picture-in-picture and hide fullscreen control when possible
      disablePictureInPicture
      controlsList="nofullscreen nodownload noremoteplayback"
    >
      Trình duyệt của bạn không hỗ trợ thẻ video.
    </video>
  );
}

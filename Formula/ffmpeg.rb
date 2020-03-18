class Ffmpeg < Formula
  desc "Play, record, convert, and stream audio and video"
  homepage "https://ffmpeg.org/"
  url "https://ffmpeg.org/releases/ffmpeg-4.2.2.tar.xz"
  sha256 "cb754255ab0ee2ea5f66f8850e1bd6ad5cac1cd855d0a2f4990fb8c668b0d29c"
  head "https://github.com/FFmpeg/FFmpeg.git"

  bottle do
    cellar :any_skip_relocation
    root_url "https://autobrew.github.io/bottles"
    sha256 "ccf70655943ec26ba729f271df501f28f46b5c24738fb94e2405b825ad6fadd1" => :el_capitan
  end

  depends_on "nasm" => :build
  depends_on "pkg-config" => :build
  depends_on "texi2html" => :build

  depends_on "lame"
  depends_on "libvorbis"
  depends_on "libvpx"
  depends_on "x264"
  depends_on "xvid"

  def install
    args = %W[
      --prefix=#{prefix}
      --enable-shared
      --enable-pthreads
      --enable-version3
      --enable-hardcoded-tables
      --enable-avresample
      --cc=#{ENV.cc}
      --host-cflags=#{ENV.cflags}
      --host-ldflags=#{ENV.ldflags}
      --enable-ffplay
      --enable-gpl
      --enable-libmp3lame
      --enable-libvorbis
      --enable-libvpx
      --enable-libx264
      --enable-libxvid
    ]

    system "./configure", *args
    system "make", "install"

    # Build and install additional FFmpeg tools
    system "make", "alltools"
    bin.install Dir["tools/*"].select { |f| File.executable? f }
  end

  test do
    # Create an example mp4 file
    mp4out = testpath/"video.mp4"
    system bin/"ffmpeg", "-filter_complex", "testsrc=rate=1:duration=1", mp4out
    assert_predicate mp4out, :exist?
  end
end

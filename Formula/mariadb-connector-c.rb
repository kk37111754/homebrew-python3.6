class MariadbConnectorC < Formula
  desc "MariaDB database connector for C applications"
  homepage "https://downloads.mariadb.org/connector-c/"
  url "https://downloads.mariadb.org/f/connector-c-3.1.7/mariadb-connector-c-3.1.7-src.tar.gz"
  sha256 "64f7bc8f5df3200ba6e3080f68ee4942382a33e8371baea8ca4b9242746df59a"

  bottle do
    cellar :any
    root_url "https://autobrew.github.io/bottles"
    sha256 "046149bed241cb5349c77dbaa891a570cd58ed7bc6dde443cc4034278112a5e3" => :el_capitan_or_later
  end

  depends_on "cmake" => :build
  depends_on "openssl@1.1"

  conflicts_with "mysql", "mariadb", "percona-server",
                 :because => "both install plugins"

  def install
    args = std_cmake_args
    args << "-DOPENSSL_INCLUDE_DIR=#{Formula["openssl@1.1"].opt_include}"

    inreplace "plugins/auth/CMakeLists.txt", "DEFAULT DYNAMIC", "DEFAULT OFF"
    inreplace "plugins/io/CMakeLists.txt", "DEFAULT DYNAMIC", "DEFAULT OFF"

    system "cmake", ".", *args
    system "make", "install"
  end

  test do
    system "#{bin}/mariadb_config", "--cflags"
  end
end

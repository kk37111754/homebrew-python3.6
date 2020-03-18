class MariadbConnectorC < Formula
  desc "MariaDB database connector for C applications"
  homepage "https://downloads.mariadb.org/connector-c/"
  url "https://downloads.mariadb.org/f/connector-c-3.1.7/mariadb-connector-c-3.1.7-src.tar.gz"
  sha256 "64f7bc8f5df3200ba6e3080f68ee4942382a33e8371baea8ca4b9242746df59a"
  revision 1
  head "https://github.com/mariadb-corporation/mariadb-connector-c.git", :branch => 3.1

  patch do
    url "https://github.com/mariadb-corporation/mariadb-connector-c/commit/fbf1db62.patch"
    sha256 "658b88969c147efa0fcd1c6d067fe6e7a63936d336d22d396c55fc0e268ee696"
  end

  bottle do
    cellar :any
    root_url "https://autobrew.github.io/bottles"
    sha256 "9fdd9109ae52e7d8fd77957c56b1c497037837c03dba06506cc96f38d0ddf38a" => :el_capitan
  end

  depends_on "cmake" => :build
  depends_on "openssl@1.1"

  conflicts_with "mysql", "mariadb", "percona-server",
                 :because => "both install plugins"

  def install
    args = std_cmake_args
    args << "-DCLIENT_PLUGIN_AUTH_GSSAPI_CLIENT=STATIC"
    args << "-DCLIENT_PLUGIN_DIALOG=STATIC"
    args << "-DCLIENT_PLUGIN_CLIENT_ED25519=STATIC"
    args << "-DCLIENT_PLUGIN_CACHING_SHA2_PASSWORD=STATIC"
    args << "-DCLIENT_PLUGIN_SHA256_PASSWORD=STATIC"
    args << "-DCLIENT_PLUGIN_MYSQL_CLEAR_PASSWORD=STATIC"
    args << "-DCLIENT_PLUGIN_MYSQL_OLD_PASSWORD=STATIC"
    args << "-DCLIENT_PLUGIN_REMOTE_IO=OFF"

    ENV["CFLAGS"] = "-DMYSQL_CLIENT=1"
    ENV["OPENSSL_ROOT_DIR"] = "/usr/local/opt/openssl@1.1"

    mkdir "build" do
      system "/usr/local/bin/cmake", "..", *args
      system "make", "install", "-j1"
    end
  end

  test do
    system "#{bin}/mariadb_config", "--cflags"
  end
end

class Qcustomplot < Formula
  desc "Qt C++ widget for plotting and data visualization"
  homepage "https://www.qcustomplot.com/"
  url "https://www.qcustomplot.com/release/2.1.1/QCustomPlot.tar.gz"
  sha256 "9afc16e70e8bd8c8d5b13020387716f5e063e115b6599f0421a3846dc6ec312a"
  license "GPL-3.0-only"

  depends_on "cmake" => :build
  depends_on "qt@5" => :build

  patch :DATA

  def install
    system "cmake", "-DCMAKE_MACOSX_RPATH=1", ".", *std_cmake_args
    system "cmake", "--build", "."

    (include/"qcustomplot").install Dir["*.h"]
    lib.install Dir["*.a", shared_library("*")]
  end

  test do
    # todo
    system "true"
  end
end

__END__
From: Anton Gladky <gladk@debian.org>
Date: Mon, 2 Nov 2020 22:39:50 +0100
Subject: Add CMakeLists files for building of shared library and to examples

Last-Update: 2018-01-30
---
 CMakeLists.txt                                     | 30 ++++++++++++++++++++++
 cmake/QCustomPlotConfig.cmake                      | 19 ++++++++++++++
 6 files changed, 129 insertions(+)
 create mode 100644 CMakeLists.txt
 create mode 100644 cmake/QCustomPlotConfig.cmake

diff --git a/CMakeLists.txt b/CMakeLists.txt
new file mode 100644
index 0000000..e8734d2
--- /dev/null
+++ b/CMakeLists.txt
@@ -0,0 +1,30 @@
+PROJECT(qcustomplot CXX)
+CMAKE_MINIMUM_REQUIRED(VERSION 2.9)
+
+SET(Q_MAJOR_VERSION "2")
+SET(Q_MINOR_VERSION "1")
+SET(Q_PATCH_VERSION "1")
+
+INCLUDE(GNUInstallDirs)
+
+find_package(Qt5 COMPONENTS Widgets PrintSupport REQUIRED)
+INCLUDE_DIRECTORIES(${Qt5Widgets_INCLUDE_DIRS} /usr/include/qt5/QtPrintSupport)
+ADD_DEFINITIONS(${Qt5Widgets_DEFINITIONS} -DQCUSTOMPLOT_COMPILE_LIBRARY)
+set(CMAKE_AUTOMOC ON)
+set(CMAKE_AUTORCC ON)
+set(CMAKE_AUTOUIC ON)
+
+
+set(Q_VERSION "${Q_MAJOR_VERSION}.${Q_MINOR_VERSION}.${Q_PATCH_VERSION}")
+set(Q_SOVERSION "${Q_MAJOR_VERSION}.${Q_MINOR_VERSION}")
+
+ADD_LIBRARY(qcustomplot SHARED qcustomplot.cpp)
+
+SET_TARGET_PROPERTIES(qcustomplot PROPERTIES
+  VERSION ${Q_VERSION}
+  SOVERSION ${Q_SOVERSION})
+TARGET_LINK_LIBRARIES(qcustomplot Qt5::Widgets Qt5::PrintSupport)
+
+INSTALL(TARGETS qcustomplot DESTINATION "${CMAKE_INSTALL_LIBDIR}")
+INSTALL(FILES qcustomplot.h DESTINATION "${CMAKE_INSTALL_INCLUDEDIR}")
+INSTALL(FILES cmake/QCustomPlotConfig.cmake DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/QCustomPlot)
diff --git a/cmake/QCustomPlotConfig.cmake b/cmake/QCustomPlotConfig.cmake
new file mode 100644
index 0000000..02da472
--- /dev/null
+++ b/cmake/QCustomPlotConfig.cmake
@@ -0,0 +1,19 @@
+# Try to find the QCustomPlot librairies
+#  QCustomPlot_FOUND - system has QCustomPlot lib
+#  QCustomPlot_INCLUDE_DIR - the GMP include directory
+#  QCustomPlot_LIBRARIES - Libraries needed to use QCustomPlot
+
+# Copyright (c) 2013, Anton Gladky <gladk@debian.org>
+#
+# Redistribution and use is allowed according to the terms of the GPL-3 license.
+
+
+IF (QCustomPlot_INCLUDE_DIR AND QCustomPlot_LIBRARIES)
+  SET(QCustomPlot_FIND_QUIETLY TRUE)
+ENDIF (QCustomPlot_INCLUDE_DIR AND QCustomPlot_LIBRARIES)
+
+FIND_PATH(QCustomPlot_INCLUDE_DIR NAMES qcustomplot.h )
+FIND_LIBRARY(QCustomPlot_LIBRARIES NAMES qcustomplot )
+
+include(FindPackageHandleStandardArgs)
+FIND_PACKAGE_HANDLE_STANDARD_ARGS(QCustomPlot DEFAULT_MSG QCustomPlot_INCLUDE_DIR QCustomPlot_LIBRARIES)

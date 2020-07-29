BRANCH = "master"
SRCREV = "ae997c498d01fadbc41d798869e1685c8d6606b7"

EXTRA_OECMAKE += "-DXRT_AIE_BUILD=yes"
TARGET_CXXFLAGS += "-DXRT_ENABLE_AIE"

DEPENDS += " libmetal libxaiengine"
RDEPENDS_${PN} += " libxaiengine"

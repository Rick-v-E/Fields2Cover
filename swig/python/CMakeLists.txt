find_package(Python REQUIRED COMPONENTS Interpreter Development)

if(Python_VERSION VERSION_LESS 3)
  message(FATAL_ERROR "Python 3 or greater is required. Python 2 is not supported.")
endif()

set(OUTPUT_FOLDER "${CMAKE_BINARY_DIR}/fields2cover_python/")
set(CMAKE_SWIG_OUTDIR ${OUTPUT_FOLDER}/fields2cover)
set(LIBRARY_OUTPUT_PATH ${OUTPUT_FOLDER}/fields2cover)

set(CMAKE_SWIG_FLAGS "-py3;-DPY3")

if(BUILD_DOC)
  list(APPEND CMAKE_SWIG_FLAGS "-doxygen")
endif()

set_source_files_properties(
  ../${PROJECT_NAME}.i
  PROPERTIES CPLUSPLUS ON
)

include_directories(
  ${CMAKE_SOURCE_DIR}/include/
  ${Python_INCLUDE_DIRS}
)

# Add swig module
SWIG_ADD_LIBRARY(fields2cover_python
  LANGUAGE python
  SOURCES ../${PROJECT_NAME}.i
)

SWIG_LINK_LIBRARIES(fields2cover_python
  Fields2Cover
  ${GDAL_LIBRARIES}
  ${CMAKE_THREAD_LIBS_INIT}
  -lgeos_c
  ${MATH_LIBRARY}
  ortools::ortools
  nlohmann_json::nlohmann_json
  tinyxml2::tinyxml2
  steering_functions
  matplot
)

# Files to install with Python
set(
  PYTHON_INSTALL_FILES
  ${OUTPUT_FOLDER}/fields2cover/fields2cover.py
  ${OUTPUT_FOLDER}/fields2cover/_fields2cover_python.so
)

# Configure setup.py and copy to output directory
configure_file(${CMAKE_CURRENT_SOURCE_DIR}/pyproject.toml.in ${OUTPUT_FOLDER}/pyproject.toml)
configure_file(${CMAKE_CURRENT_SOURCE_DIR}/MANIFEST.in ${OUTPUT_FOLDER}/MANIFEST.in COPYONLY)
configure_file(${CMAKE_SOURCE_DIR}/LICENSE ${OUTPUT_FOLDER}/LICENSE COPYONLY)
configure_file(${CMAKE_SOURCE_DIR}/README.rst ${OUTPUT_FOLDER}/README.rst COPYONLY)
configure_file(${CMAKE_CURRENT_SOURCE_DIR}/__init__.py.in ${OUTPUT_FOLDER}/fields2cover/__init__.py COPYONLY)

set_target_properties(fields2cover_python PROPERTIES
    BUILD_RPATH "$ORIGIN"
    INSTALL_RPATH "$ORIGIN"
)

add_custom_command(TARGET fields2cover_python POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E copy ${CMAKE_BINARY_DIR}/libFields2Cover.so ${OUTPUT_FOLDER}/fields2cover/  # Add fields2cover
    COMMAND ${CMAKE_COMMAND} -E copy ${ortools_SOURCE_DIR}/lib/libortools.so.9 ${OUTPUT_FOLDER}/fields2cover/  # Add ortools
)

# Install target to call setup.py
add_custom_target(install-python
  DEPENDS fields2cover_python
  COMMAND python3 ${SETUP_PY_OUT} install --prefix=${CMAKE_INSTALL_PREFIX}
)
install(CODE "execute_process(COMMAND python3 -m pip install ${OUTPUT_FOLDER} --prefix=${CMAKE_INSTALL_PREFIX})")

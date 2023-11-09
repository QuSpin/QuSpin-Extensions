find src/ -name "*.so" | xargs rm -rf
find src/ -name "*.cpp" | xargs rm -rf
find src/ -name "*.c" | xargs rm -rf
find src/ -name "*.pyc" | xargs rm -rf
find src/ -name "build" | xargs rm -rf
find src/ -name "__pycache__" | xargs rm -rf

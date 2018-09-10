from distutils.core import setup
from Cython.Build import cythonize

setup(name='cy messager',
      ext_modules=cythonize("cy_messager.pyx"))
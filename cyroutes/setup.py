from distutils.core import setup
from Cython.Build import cythonize


setup(name='cy_routes',
      ext_modules=cythonize("routes_cy.pyx"))


FROM fuzzers/afl:2.52 as builder

RUN apt-get update
RUN apt install -y  build-essential wget git clang cmake zlib1g zlib1g-dev
ADD . /lunasvg
WORKDIR /lunasvg
RUN cmake -DCMAKE_C_COMPILER=afl-clang -DCMAKE_CXX_COMPILER=afl-clang++ -DBUILD_SHARED_LIBS=true .
RUN make
RUN make install
WORKDIR /lunasvg/example
RUN cmake -DCMAKE_C_COMPILER=afl-clang -DCMAKE_CC_COMPILER=afl-clang++ .
RUN make
RUN wget https://dev.w3.org/SVG/tools/svgweb/samples/svg-files/AJ_Digital_Camera.svg
RUN wget https://dev.w3.org/SVG/tools/svgweb/samples/svg-files/Steps.svg
RUN wget https://dev.w3.org/SVG/tools/svgweb/samples/svg-files/acid.svg
RUN wget https://dev.w3.org/SVG/tools/svgweb/samples/svg-files/aa.svg
RUN wget https://dev.w3.org/SVG/tools/svgweb/samples/svg-files/adobe.svg
RUN wget https://dev.w3.org/SVG/tools/svgweb/samples/svg-files/anim1.svg
RUN wget https://dev.w3.org/SVG/tools/svgweb/samples/svg-files/atom.svg

FROM fuzzers/afl:2.52
COPY --from=builder /lunasvg/example/svg2png /
COPY --from=builder /lunasvg/example/*.svg /testsuite/
COPY --from=builder /usr/local/lib/* /usr/local/lib/
COPY --from=builder /lunasvg/lib* /usr/local/lib/
# Find the liblunasvg.so
ENV LD_LIBRARY_PATH /usr/local/lib

ENTRYPOINT ["afl-fuzz", "-i", "/testsuite/", "-o", "/lunaSvgOut"]
CMD ["/svg2png", "@@"]

FROM fuzzers/afl:2.52

RUN apt-get update
RUN apt install -y  build-essential wget git clang cmake zlib1g zlib1g-dev
RUN git clone https://github.com/sammycage/lunasvg
WORKDIR /lunasvg
RUN cmake -DCMAKE_C_COMPILER=afl-clang -DCMAKE_CXX_COMPILER=afl-clang++ -DBUILD_SHARED_LIBS=true .
RUN make
RUN make install
WORKDIR /lunasvg/example
RUN cmake -DCMAKE_C_COMPILER=afl-clang -DCMAKE_CC_COMPILER=afl-clang++ .
RUN make
RUN cp ./svg2png /svg2png
WORKDIR /lunasvg
RUN mkdir /lunasvgCorpus
RUN wget https://dev.w3.org/SVG/tools/svgweb/samples/svg-files/AJ_Digital_Camera.svg
RUN wget https://dev.w3.org/SVG/tools/svgweb/samples/svg-files/Steps.svg
RUN wget https://dev.w3.org/SVG/tools/svgweb/samples/svg-files/acid.svg
RUN wget https://dev.w3.org/SVG/tools/svgweb/samples/svg-files/aa.svg
RUN wget https://dev.w3.org/SVG/tools/svgweb/samples/svg-files/adobe.svg
RUN wget https://dev.w3.org/SVG/tools/svgweb/samples/svg-files/anim1.svg
RUN wget https://dev.w3.org/SVG/tools/svgweb/samples/svg-files/atom.svg
RUN mv *.svg /lunasvgCorpus
ENV LD_LIBRARY_PATH=/usr/local/lib

ENTRYPOINT ["afl-fuzz", "-i", "/lunasvgCorpus", "-o", "/lunaSvgOut"]
CMD ["/svg2png", "@@"]

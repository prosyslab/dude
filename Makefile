all:
	dune build src/main.exe
	ln -sf _build/default/src/main.exe dude

clean:
	dune clean
	rm -rf dude

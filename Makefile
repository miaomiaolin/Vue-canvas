.PHONY: build

dev:
	@npm run dev

build:
	@npm run build

move:
	@npm run build
	rm -rf web
	test -d web/views || mkdir -p web/views
	cp -r dist/static web/static
	cp dist/*.html web/views
	cp -r dist/push-* web/views 
	rm -rf ../tag1801/clweb/web
	mv web ../tag1801/clweb

deploy:
	@npm run build
	test -d web/views || mkdir -p web/views
	cp -r dist/static web/static
	cp dist/*.html web/views
	cp -r dist/push-* web/views
	tar -cjvf web.tar.bz2 web 
	rm -rf web

publish: deploy
	scp web.tar.bz2 root@47.104.251.44:/work/online/tag1801/clweb/
	ssh root@47.104.251.44 "cd /work/online/tag1801/clweb; tar -xjvf web.tar.bz2"
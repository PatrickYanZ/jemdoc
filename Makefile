# Members
# MEMBER_DOCS= \
# 	members/member1/index members/member2/index members/member3/index

# Teaching
# TEACHING_DOCS= \
# 	teaching/course1/index teaching/course2/index teaching/course3/index

# Software
# SOFTWARE_DOCS= \
# 	software/tool1/index software/tool2/index  software/tool3/index

# Research
RESEARCH_DOCS= \
	research/topic1/index research/topic2/index research/topic3/index research/topic4/index research/topic5/index

# All Jemdoc files
# DOCS=index teaching members research publications software news contacts $(TEACHING_DOCS) $(MEMBER_DOCS) $(RESEARCH_DOCS) $(SOFTWARE_DOCS)
DOCS=index research publications experiences awards $(RESEARCH_DOCS) 
## HTML Files
HDOCS=$(addsuffix .html, $(DOCS))
PHDOCS=$(addprefix html/, $(HDOCS))

.PHONY : all
all : $(PHDOCS)
	-if exist html\*.jemdoc del /Q html\*.jemdoc
	-if exist html\Default.aspx del /Q html\Default.aspx
	-if exist html\Default.aspx.cs del /Q html\Default.aspx.cs
	-if exist html\edit.aspx.designer.cs del /Q html\edit.aspx.designer.cs
	-if exist html\news.html del /Q html\news.html
	-if exist html\news.rss del /Q html\news.rss
	-if exist html\rss.js del /Q html\rss.js
	-if exist html\urls.json del /Q html\urls.json
	-if exist html\Web.config del /Q html\Web.config
	-if exist html\*.jpg del /Q html\*.jpg
	-if exist html\*.jpeg del /Q html\*.jpeg
	-if exist html\*.png del /Q html\*.png
	-if exist html\*.gif del /Q html\*.gif
	-if exist html\*.webp del /Q html\*.webp
	-if exist jemdoc\images if not exist html\images mkdir html\images
	-if exist jemdoc\images xcopy /E /I /Y /Q jemdoc\images html\images >nul
	-if exist jemdoc\rss if not exist html\rss mkdir html\rss
	-if exist jemdoc\rss xcopy /E /I /Y /Q jemdoc\rss html\rss >nul
	-if exist eqs xcopy /E /I /Y /Q eqs html >nul
	@echo "Website building is complete !"

html/%.html : jemdoc/%.jemdoc jemdoc/jemdoc.css
	@if not exist "$(subst /,\,$(dir $@))" mkdir "$(subst /,\,$(dir $@))"
	-if exist "$(subst /,\,$(dir $<))*.*" xcopy /E /I /Y /Q "$(subst /,\,$(dir $<))*.*" "$(subst /,\,$(dir $@))" >nul
	-if exist "$(subst /,\,$(dir $@))$(notdir $<)" del /Q "$(subst /,\,$(dir $@))$(notdir $<)"
	python jemdoc.py -c website.conf -o $@ $<

.PHONY : clean
clean :
	-if exist html rmdir /S /Q html
	-if exist eqs rmdir /S /Q eqs

.PHONY : install
install :
	curl https://jemdoc.jaboc.net/dist/jemdoc.py > ./jemdoc.py
	chmod +x ./jemdoc.py

.PHONY : pull
pull :
	git pull

.PHONY : push
push :
	git add .
	git commit -m"Some modifications"
	git push
	
.PHONY : publishall
publishall :
	$(eval ftp_site := mywebsite.com)
	$(eval FTP_MIRROR_PATH := html)
	$(eval USERNAME ?= $(shell read -p "FTP Username: " pwd; echo $$pwd))
	$(eval PASSWORD ?= $(shell read -p "FTP Password: " pwd; echo $$pwd))
	$(MAKE) pull
	lftp -e "set ftp:ssl-allow no; set xfer:clobber on; get /rss/news.rss; exit" -u $(USERNAME),$(PASSWORD) $(ftp_site)
	cp news.rss ./news_bkp/$(shell date --iso=seconds).rss	
	mv news.rss ./html/rss/
	$(MAKE) push -i
	$(MAKE) all	
	lftp -e "set ftp:ssl-allow no; mirror -Rne ./$(FTP_MIRROR_PATH) /; exit" -u $(USERNAME),$(PASSWORD) $(ftp_site)
	
	
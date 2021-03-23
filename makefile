include config.mk

## all: list of all targets in makefile
all : ukb.db

## help: list of all targets and what they do
.PHONY : help
help : Makefile
	@sed -n 's/^##//p' $<

## ukb.db: generate ukb.db
ukb.db : $(ALL_SETUP_FILES)
	RScript setup/setup_renv.R
	bash setup/setup_caliber.sh
	bash setup/setup_ukb_primarycare_codings.sh
	bash setup/setup_ukb_data_dict_and_codings.sh
	RScript setup/ukb_data_dict_codings_to_db.R

## clean: remove ukb.db, downloaded files and contents of Rdata
.PHONY : clean
clean :
	rm -i ukb.db
	rm -r renv/library/
	rm -r caliber
	rm -r ukb_primarycare_codings
	rm -r ukb_data_dict_and_codings
	rm Rdata/*

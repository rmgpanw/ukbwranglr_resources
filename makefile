include config.mk

## all: list of all targets in makefile
all : ukb.db

## help: list of all targets and what they do
.PHONY : help
help : Makefile
	@sed -n 's/^##//p' $<

## ukb.db: generate ukb.db
ukb.db : $(ALL_SETUP_FILES)
	bash setup/setup_renv.R
	bash setup/setup_caliber.sh
	bash setup/setup_ukb_primarycare_codings.sh

## clean: remove ukb.db
.PHONY : clean
clean :
	rm -i ukb.db
	rm -ri caliber/data/
	rm -ri ukb_primarycare_codings/data/
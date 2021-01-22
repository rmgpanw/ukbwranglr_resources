include config.mk

## help: list of all targets and what they do
.PHONY: help
help : Makefile
	@sed -n 's/^##//p' $<

## ukb.db: generate ukb.db
ukb.db : $(ALL_SETUP_FILES)
	bash setup/setup_caliber.sh
	bash setup/setup_ukb_primary_care_codings.sh

## clean: remove ukb.db
.PHONY: clean
clean:
	rm ukb.db
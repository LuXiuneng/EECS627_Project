PIC_LD=ld

ARCHIVE_OBJS=
ARCHIVE_OBJS += _24200_archive_1.so
_24200_archive_1.so : archive.5/_24200_archive_1.a
	@$(AR) -s $<
	@$(PIC_LD) -shared  -o .//../dve.daidir//_24200_archive_1.so --whole-archive $< --no-whole-archive
	@rm -f $@
	@ln -sf .//../dve.daidir//_24200_archive_1.so $@






%.o: %.c
	$(CC_CG) $(CFLAGS_CG) -c -o $@ $<
CU_UDP_OBJS = \


CU_LVL_OBJS = \
SIM_l.o 

MAIN_OBJS = \
objs/amcQw_d.o 

CU_OBJS = $(MAIN_OBJS) $(ARCHIVE_OBJS) $(CU_UDP_OBJS) $(CU_LVL_OBJS)


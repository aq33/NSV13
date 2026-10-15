// AQ EDIT - plumbing port from tg (tgstation/tgstation@1568dbe1da)
#define FIRST_DUCT_LAYER (1<<0)
#define SECOND_DUCT_LAYER (1<<1)
#define THIRD_DUCT_LAYER (1<<2)
#define FOURTH_DUCT_LAYER (1<<3)
#define FIFTH_DUCT_LAYER (1<<4)

#define DUCT_LAYER_DEFAULT THIRD_DUCT_LAYER

#define MACHINE_REAGENT_TRANSFER 10 //the default max plumbing machinery transfers

/// Plumbing ducts and connector overlays sit just above visible gas pipes
#define PLUMBING_PIPE_VISIBILE_LAYER 2.495

/// Duct color that connects with every other duct color
#define DUCT_COLOR_OMNI "omni"

/// Seconds between plumbing subsystem ticks
#define SSPLUMBING_DT 1

///Plumbing Acclimator is filling
#define AC_FILLING 0
///Plumbing Acclimator is heating
#define AC_HEATING 1
///Plumbing Acclimator is cooling
#define AC_COOLING 2
///Plumbing Acclimator is emptying
#define AC_EMPTYING 3

///Plumbing automatic buffer is still receiving reagents
#define AB_UNREADY 0
///Plumbing automatic buffer is waiting on other buffers to get ready
#define AB_IDLE 1
///Plumbing automatic buffer is sending reagents
#define AB_READY 2

/// Default water stored by sinks
#define SINK_CAPACITY 100
/// Water used by washing once in a sink
#define SINK_WASH_VOLUME 5
/// Default water stored in a toilet cistern
#define TOILET_CAPACITY 200
/// Water used by one toilet flush
#define TOILET_FLUSH_VOLUME 50
/// Default water stored by showers
#define SHOWER_CAPACITY 200
/// Water a shower uses per second while running
#define SHOWER_SPRAY_VOLUME 5
/// Water a fixture with a recycler reclaims per second
#define WATER_RECLAIM_RATE 0.5

/// Sent to a plumbing atom when its ducting layer should change: (obj/changer, new_layer)
#define COMSIG_MOVABLE_CHANGE_DUCT_LAYER "movable_change_duct_layer"

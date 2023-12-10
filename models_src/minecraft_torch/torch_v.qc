
$modelname		"minecraft/torch_v.mdl"
$model "torch_v" "torch_v.smd"
$cdmaterials	"minecraft"

$attachment "muzzle" "muzzle" 0 0 0 rotate 0.00 0.00 0.00

$sequence draw "torch_v_draw" ACT_VM_DRAW 1 fps 30.00
$sequence idle "torch_v_idle" loop ACT_VM_IDLE 1 fps 1.00
$sequence fire "torch_v_fire" ACT_VM_PRIMARYATTACK 1 fps 24.00 node Fire

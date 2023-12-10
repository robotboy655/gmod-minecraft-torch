
$modelname		"minecraft/torch_w.mdl"
$body	"torch_w"	"torch_w.smd"
$cdmaterials	"minecraft"

$surfaceprop	"wood"

$attachment "muzzle" "muzzle" 0 0 0 rotate 0.00 0.00 0.00

$sequence idle "torch_w_idle" loop ACT_VM_IDLE 1 fps 1.00

$collisionmodel	"torch_w.smd"
{ 
	$mass 2.0
}

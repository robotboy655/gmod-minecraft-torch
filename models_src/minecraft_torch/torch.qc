
$modelname		"minecraft/torch.mdl"
$body	"torch"	"torch.smd"
$cdmaterials	"minecraft"

$surfaceprop	"wood"

$attachment "muzzle" "muzzle" 0 0 0 rotate 0.00 0.00 0.00

$sequence idle	"torch_idle.smd" loop fps 1

$collisionmodel	"torch.smd"
{ 
	$mass 2.0
}

const CARDS = { #Atack, hp, Trust_cost, Card_Type, Ability text, ability script, owner, subcategory
	"DOL_Happy": [16, 1000 ,2, "memory", null, null, "DOL", "Happy"],
	"DBL_Happy": [32, 1000, 4, "memory", null, null, "DBL", "Happy"], 
	"DAL_Happy": [28, 1000, 3, "memory", "Deal 50 damage to opponent when played", "res://scripts/Battle/Abilities/Arrow.gd", "DAL", "Happy"], 
	"Fear_Happy": [42, 1000, 50, "memory", "If this card attacks, it can attack once again", "res://scripts/Battle/Abilities/AttackTwice.gd", "Fear", "Happy"], 
	"Trismegistus_Bomb": [null, null, null, "event", "Deal 50 damage to all opponent cards.", "res://scripts/Battle/Abilities/Bomb.gd", "Trismegistus", "Bomb"]
}

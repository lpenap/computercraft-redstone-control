--[[
	Author: lpenap
	Last update: 2017-09
	Pastebin: 
	https://github.com/lpenap/computercraft-redstone-control

	Description:
	This program let you have a central control
	station for several client computers that relays
	redstone signals (You can turn ON/OFF remote
	machines with redstone from a central computer).

	Save this file as "startup" on your computer for
	it to auto-start on Computer boot.
	To easily get this file into your Computercraft
	Computer, run the following after right-clicking
	on your computer:

	pastebin  ZTMzRLez run
	
	Additional info and instructions available on
	Github repository.

]]--

os.setComputerLabel("RedstoneControlClient")
shell.run("redstoneclient")

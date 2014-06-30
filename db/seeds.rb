# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)


Post.create([
	{title: 'El Edificio del Cierre', 
	location: '(-34.904621, -56.160526)', 
	date: DateTime.now, 
	author: 'Mathias Carignani'},
	{title: 'Mi Casa', 
	location: '(-34.877938, -56.062293)', 
	date: DateTime.now, 
	author: 'Juan Andres Rodriguez'},
	{title: 'Estadio', 
	location: '(-34.894246, -56.152721)', 
	date: DateTime.now, 
	author: 'Mario Balotelli'},
	{title: 'Muzzarella Trouville', 
	location: '(-34.920316, -56.150339)', 
	date: DateTime.now, 
	author: 'Damian Marcos'}


	]) 
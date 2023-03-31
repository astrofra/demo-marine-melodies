-- demo scroll text

scroll_text = "   "
scroll_text = scroll_text .. "                                                                                                       "
scroll_text = scroll_text .. "                                                                                                       "
-- start

scroll_text = scroll_text .. "Bienvenue dans 'Marine Melodies', une experience musico-aquatique contemplative ..."
scroll_text = scroll_text .. "   -   "
scroll_text = scroll_text .. "Concept, graphismes, code : Astrofra"
scroll_text = scroll_text .. "   -   "
scroll_text = scroll_text .. "Design d'interaction : Romboyj"
scroll_text = scroll_text .. "   -   "
scroll_text = scroll_text .. "Compositeurs : Aceman, Erk, GliGli, mAZE, Nainain, Riddlemak, WillBe"
scroll_text = scroll_text .. "   -   "
scroll_text = scroll_text .. "Assistance au code : Erk"
scroll_text = scroll_text .. "   -   "
scroll_text = scroll_text .. "Interface tangible : Gaziel"
scroll_text = scroll_text .. "   -   "
scroll_text = scroll_text .. "Moteur 3D : HARFANG"
scroll_text = scroll_text .. ", "
scroll_text = scroll_text .. "Remerciements a Kipixelle, Mooz, Scorpheus, Xbarr pour le meilleur moteur 3D du monde!  "
scroll_text = scroll_text .. "Remerciements au collectif Resistance Norway (resistance.no)!  "
scroll_text = scroll_text .. " "

scroll_text = scroll_text .. "   -   "
scroll_text = scroll_text .. "Morceaux/Compositeurs, par ordre dans la liste de lecture : "

scroll_text = scroll_text .. "'Elsewhere' par Erk" .. ", "
scroll_text = scroll_text .. "'Of Lobsters and Men' par Aceman" .. ", "
scroll_text = scroll_text .. "'Sweet Mermaids' par Nainain" .. ", "
scroll_text = scroll_text .. "'Coral Pillows' par willBe" .. ", "
scroll_text = scroll_text .. "'6502 Fathoms' par mAZE" .. ", "
scroll_text = scroll_text .. "'Mountains City' par Erk" .. ", "
scroll_text = scroll_text .. "'Underwater' par GliGli" .. ", "
scroll_text = scroll_text .. "'Electronics Underground' par Erk" .. ", "
scroll_text = scroll_text .. "'A.I.' par Riddlemak"

scroll_text = scroll_text .. "   -   "

scroll_text = scroll_text .. "Installez vous, prenez le casque et laissez-vous aller ... "
scroll_text = scroll_text .. "Appuez sur le bouton du walkman pour changer de morceau ... "

scroll_text = scroll_text .. "   -   "

scroll_text = scroll_text .. "Merci, tout le XUL, pour cet espace d'exposition ... " 

scroll_text = scroll_text .. "Ce projet a commence comme... un niveau pour un jeu video. Le jeu devait être une course spatiale, "
scroll_text = scroll_text .. "avec des vaisseaux ultra rapides parcourant differents circuits. Le gameplay etait en 2D mais "
scroll_text = scroll_text .. "l'affichage etait entierement en 3D (utilisant une pre-version du moteur HARFANG...) "
scroll_text = scroll_text .. "L'idee etait de modeliser de beaux paysages en 3D qui apparaîtraient en arriere-plan de chaque niveau. "
scroll_text = scroll_text .. "J'ai discute avec l'equipe et suggere que je pourrais travailler sur certaines des scenes d'arriere-plan... "
scroll_text = scroll_text .. "Le jeu n'est finalement jamais sorti, mais j'ai conserve les fichiers 3D... "
scroll_text = scroll_text .. "Aa final, cette scene 3D est tiree un niveau d'un jeu qui ne fut point... "
scroll_text = scroll_text .. " "

scroll_text = scroll_text .. "L'idee de transformer cette scene 3D en une exprience musicale est venue progressivement... Nainain venait d'installer son nouveau studio d'enregistrement musical chez lui "
scroll_text = scroll_text .. "et a avait commence a le tester sur des compositions originales. Il m'a envoye l'une de ses maquettes qui etait vraiment prometteuse "
scroll_text = scroll_text .. "et correspondait parfaitement a cette scene 3D aquatique que j'avais sur mon disque dur, alors nous avons eu l'idee d'une petite demo... "
scroll_text = scroll_text .. "Mais... de cette idee de demo, j'ai commence a demander aux copains du collectif Resistance et d'ailleurs "
scroll_text = scroll_text .. "s'ils seraient interesses pour contribuer a au projet. "
scroll_text = scroll_text .. "Le look visuel etait presque entierement termine et j'imagine que cela a aide a fournir de l'inspiration et de la motivation... "
scroll_text = scroll_text .. " "

scroll_text = scroll_text .. "Du côte technique, cette demo est construite sur le moteur 3D HARFANG... "
scroll_text = scroll_text .. "Qu'est-ce que HARFANG? C'est un moteur 3D data-driven qui fonctionne presque partout, "
scroll_text = scroll_text .. "comme un module Golang, comme un SDK C++, comme une extension Lua ou encore un module Python,"
scroll_text = scroll_text .. "qui est le cas de cette demo! "
scroll_text = scroll_text .. "Cela signifie que toute cette demo a ete scriptee en Python, y compris les interactions "
scroll_text = scroll_text .. "et les effets visuels / personnalises et le pipeline de rendu (sorte de)... "
scroll_text = scroll_text .. "Venez decouvrir HARFANG sur www.harfang3d.com ou sur Github puisqu'il est open source!"
scroll_text = scroll_text .. " "

scroll_text = scroll_text .. " ... "

scroll_text = scroll_text .. " "
scroll_text = scroll_text .. "Ceci conclut la fin de ce scrolltext, il va maintenant boucler :) ... "

-- end
scroll_text = scroll_text .. "                                                                                                       "

local scroll_char_len = 120

-- scroll text drawing routine
-- on-screen usage text
function update_demo_scroll_text(dt, view_id, res_x, res_y, scroll_x, char_offset, ns, scroll_text, font, font_program, font_size, text_render_state, fade, y_offset)
	fade = fade or 1.0
	y_offset = y_offset or 0.0
	scroll_x = scroll_x + hg.time_to_sec_f(dt) * 60.0 * 1.5 -- math.min(1.0/60.0, hg.time_from_sec_f(dt)) * 60.0

	if (scroll_x > ns) then
		scroll_x = 0
		char_offset = char_offset + 1
		local _r = hg.ComputeTextRect(font, scroll_text:sub(char_offset, char_offset))
		ns = _r.ex - _r.sx
	end
	local text_pos = hg.Vec3(-(16 * res_x) / 1280, res_y - (font_size * 1.25), 0)
	text_pos.x = text_pos.x - scroll_x
	text_pos.y = text_pos.y + (y_offset * (res_x / 1280.0))

	local text_sub = scroll_text:sub(char_offset, char_offset + scroll_char_len)

	local bold_radius = (5.0 * res_x) / 1280
	for l = 0, math.floor(bold_radius), 2 do
		for a = 0, 360, 60 do
			local bold_offset = hg.Vec3(math.cos(a * math.pi / 180.0), math.sin(a * math.pi / 180.0), 0.0) * bold_radius
			bold_offset.x = bold_offset.x + l
			bold_offset.y = bold_offset.y + l
			hg.DrawText(view_id, font, text_sub, font_program, 'u_tex', 0, hg.Mat4.Identity, text_pos + bold_offset, 
			hg.DTHA_Left, hg.DTVA_Bottom, {hg.MakeUniformSetValue('u_color', hg.Vec4(0, 0.075, 0.1, fade))}, {}, text_render_state)
		end
	end
	
	hg.DrawText(view_id, font, text_sub, font_program, 'u_tex', 0, hg.Mat4.Identity, text_pos, hg.DTHA_Left, hg.DTVA_Bottom, {hg.MakeUniformSetValue('u_color', hg.Vec4(0, 0.45, 0.5, fade))}, {}, text_render_state)

	if char_offset > string.len(scroll_text) then
		char_offset = 0
	end

	return view_id, scroll_x, char_offset, ns
end
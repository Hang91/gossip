defmodule TOPOLOGIES.Pushsum_actor do
	use GenServer

	def start_link(name, process_num, topo) do
		s = String.to_integer(name)
		w = 1
		count = 0
		sum = 0
		run = true
		GenServer.start_link(__MODULE__,[s,w,count,sum,process_num,name,topo,[],MapSet.new,run], [name: String.to_atom(name)])
	end

	def handle_call(request, _from,[s,w,count,sum,process_num,name,topo,neighbors,froms,run]) do
		
		case request do
			{:msg, msg_s,msg_w,from} ->
				from_num = String.to_integer(from)
				new_froms =
				case MapSet.member?(froms,from_num) || from_num == 0 do
					true -> froms
					false -> MapSet.put(froms,from_num)
				end

				case count do
					0 -> 
						case topo do
							1 ->
								neighbors = for n <- 1..process_num do
									neighbors = 
									case String.to_integer(name) != n do
										true -> 
											List.insert_at(neighbors,0,n)
										false ->
											neighbors
									end
								end
								neighbors = List.flatten(neighbors)
								new_s = s + msg_s
								new_w = w + msg_w
								spawn fn -> send_message(name,new_s/2,new_w/2,neighbors) end
								send String.to_atom("0"), {:update}
								{:reply,:ok, [new_s/2,new_w/2,count + 1,sum,process_num,name,topo,neighbors,new_froms,run]}
							2 ->
								line_num = round(:math.sqrt(process_num))
								offsets = [0,1,0,-1,1,0,-1,0]

								row = round(Float.floor((String.to_integer(name) - 1) / line_num))
								col = rem (String.to_integer(name) - 1),line_num
								neighbors = for n <- 0..3 do
									{offsetx,offsets} = List.pop_at(offsets,n*2)
									{offsety,offsets} = List.pop_at(offsets,n*2)
									next_row = row + offsetx
									next_col = col + offsety
									neighbors = 
									case next_row >= 0 && next_row < line_num && next_col >= 0 && next_col < line_num do
										true ->
											num = round((next_row) * line_num + next_col) + 1
											List.insert_at(neighbors,0,num)
										false ->
											neighbors
									end
								end
								neighbors = List.flatten(neighbors)
								new_s = s + msg_s
								new_w = w + msg_w
								spawn fn -> send_message(name,new_s/2,new_w/2,neighbors) end
								send String.to_atom("0"), {:update}
								{:reply,:ok,[new_s/2,new_w/2,count + 1,sum,process_num,name,topo,neighbors,new_froms,run]}
							3 ->
								name_num = String.to_integer(name)
								neighbors = 
								case name_num != 1 do
									true ->
										List.insert_at(neighbors,0,name_num - 1)
									false ->
										neighbors
								end

								neighbors = 
								case name_num != process_num do
									true ->
										List.insert_at(neighbors,0,name_num + 1)
									false ->
										neighbors
								end
								neighbors = List.flatten(neighbors)
								new_s = s + msg_s
								new_w = w + msg_w
								spawn fn -> send_message(name,new_s/2,new_w/2,neighbors) end
								send String.to_atom("0"), {:update}
								{:reply,:ok,[new_s/2,new_w/2,count + 1,sum,process_num,name,topo,neighbors,new_froms,run]}
							4 ->
								line_num = round(:math.sqrt(process_num))
								offsets = [0,1,0,-1,1,0,-1,0]

								row = round(Float.floor((String.to_integer(name) - 1) / line_num))
								col = rem (String.to_integer(name) - 1),line_num
								neighbors = for n <- 0..3 do
									{offsetx,offsets} = List.pop_at(offsets,n*2)
									{offsety,offsets} = List.pop_at(offsets,n*2)
									next_row = row + offsetx
									next_col = col + offsety
									neighbors = 
									case next_row >= 0 && next_row < line_num && next_col >= 0 && next_col < line_num do
										true ->
											num = round((next_row) * line_num + next_col) + 1
											List.insert_at(neighbors,0,num)
										false ->
											neighbors
									end
								end

								not_random_neighbors = MapSet.new(List.flatten(neighbors))
								not_random_neighbors = MapSet.put(not_random_neighbors, String.to_integer(name))
								
								p_random_neighbors = []
								p_random_neighbors =
								for n <- 1..process_num do
									p_random_neighbors = 
									case MapSet.member?(not_random_neighbors,n)do
										false ->
											List.insert_at(p_random_neighbors,0,n)
										true ->
											p_random_neighbors
									end
								end
								p_random_neighbors = List.flatten(p_random_neighbors)
								neighbors = List.insert_at(neighbors,0,Enum.random(p_random_neighbors))

								neighbors = List.flatten(neighbors)
							
								new_s = s + msg_s
								new_w = w + msg_w
								spawn fn -> send_message(name,new_s/2,new_w/2,neighbors) end
								send String.to_atom("0"), {:update}
								{:reply,:ok, [new_s/2,new_w/2,count + 1,sum,process_num,name,topo,neighbors,new_froms,run]}								
						end
					_ ->
						new_s = s + msg_s
						new_w = w + msg_w
						new_sum =
						case abs(s/w - new_s/new_w) < 0.0000000001 do
							true -> 
								sum + 1
							false -> 0
						end	

						spawn fn -> send_message(name,new_s/2,new_w/2,neighbors) end


						run = 
						case new_sum == 3 || List.first(neighbors) == nil do
							true -> 
								if run do
									send String.to_atom("0"), {:stop}
								end
								false
							false ->
								true
						end

	
						{:reply,:ok, [new_s/2,new_w/2,count + 1,new_sum,process_num,name,topo,neighbors,froms,run]}	
				end
		end
	end

	def stop_link(froms,name) do
		if MapSet.size(froms) != 0 do
			for n <- froms do
				target = "#{n}"
				GenServer.call String.to_atom(target), {:stop, name}
			end
		end
	end

	def send_message(name,s,w,neighbors) do
		if List.first(neighbors) != nil do
			i = Enum.random(neighbors)
			target = "#{i}"
			GenServer.call String.to_atom(target), {:msg,s,w,name}
		end
	end	

end
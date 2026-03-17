PRAGMA journal_mode=WAL;

CREATE TABLE agents (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  key TEXT UNIQUE NOT NULL,
  display_name TEXT NOT NULL,
  role TEXT NOT NULL DEFAULT 'executor',
  system_prompt TEXT NOT NULL,
  available_tools TEXT NOT NULL,
  model TEXT NOT NULL,
  description TEXT,
  enabled INTEGER DEFAULT 1,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  memory TEXT,
  prompts TEXT
);

CREATE TABLE chats (
  id INTEGER PRIMARY KEY,
  chat_type TEXT,
  helper_name TEXT,
  agent_type TEXT DEFAULT 'orchestrator',
  delegation_id INTEGER,
  user_message TEXT,
  assistant_message TEXT,
  thread_id TEXT,
  focused_node_id INTEGER,
  created_at TEXT DEFAULT (CURRENT_TIMESTAMP),
  metadata TEXT,
  FOREIGN KEY (focused_node_id) REFERENCES nodes(id) ON DELETE SET NULL
);

CREATE TABLE chunks (
  id INTEGER PRIMARY KEY,
  node_id INTEGER NOT NULL,
  chunk_idx INTEGER,
  text TEXT,
  created_at TEXT,
  embedding_type TEXT DEFAULT 'text-embedding-3-small',
  metadata TEXT,
  FOREIGN KEY (node_id) REFERENCES nodes(id) ON DELETE CASCADE
);

CREATE TABLE dimensions (
  name TEXT PRIMARY KEY,
  description TEXT,
  icon TEXT,
  is_priority INTEGER DEFAULT 0,
  updated_at TEXT DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE edges (
  id INTEGER PRIMARY KEY,
  from_node_id INTEGER NOT NULL,
  to_node_id INTEGER NOT NULL,
  source TEXT,
  created_at TEXT,
  context TEXT,
  FOREIGN KEY (from_node_id) REFERENCES nodes(id) ON DELETE CASCADE,
  FOREIGN KEY (to_node_id) REFERENCES nodes(id) ON DELETE CASCADE
);

CREATE TABLE logs (
            id INTEGER PRIMARY KEY,
            ts TEXT NOT NULL DEFAULT (CURRENT_TIMESTAMP),
            table_name TEXT NOT NULL,
            action TEXT NOT NULL,
            row_id INTEGER NOT NULL,
            summary TEXT,
            snapshot_json TEXT
          );

CREATE TABLE node_dimensions (
  node_id INTEGER NOT NULL,
  dimension TEXT NOT NULL,
  PRIMARY KEY (node_id, dimension),
  FOREIGN KEY (node_id) REFERENCES nodes(id) ON DELETE CASCADE
) WITHOUT ROWID;

CREATE TABLE nodes (
  id INTEGER PRIMARY KEY,
  title TEXT,
  description TEXT,
  notes TEXT,
  link TEXT,
  event_date TEXT,
  created_at TEXT,
  updated_at TEXT,
  metadata TEXT,
  chunk TEXT,
  embedding BLOB,
  embedding_updated_at TEXT,
  embedding_text TEXT,
  chunk_status TEXT DEFAULT 'not_chunked'
);

CREATE TABLE voice_usage (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          chat_id INTEGER,
          session_id TEXT,
          helper_name TEXT,
          request_id TEXT,
          message_id TEXT,
          voice TEXT,
          model TEXT,
          chars INTEGER,
          cost_usd REAL,
          duration_ms INTEGER,
          text_preview TEXT,
          created_at TEXT DEFAULT CURRENT_TIMESTAMP,
          FOREIGN KEY (chat_id) REFERENCES chats(id) ON DELETE SET NULL
        );

INSERT OR IGNORE INTO nodes (id,title,description,notes,link,event_date,created_at,updated_at,metadata,chunk,embedding,embedding_updated_at,embedding_text,chunk_status) VALUES (1,'Huge Papa','Identity anchor — Huge Papa is a game developer, Rocket League YouTuber, rapper/poet, philosopher, comic enthusiast, and AI builder using a second brain to synthesize research, predict trends, and generate new insights.','Active domains: Godot game development, Rocket League YouTube content, rap and creative writing, AI/tech research, mental health and wellness. Goal: use the knowledge graph to compile information, surface connections, and form new thoughts. Style: mix of executor, note-taker, and connector. Prefers concise+direct but also conversational. Wants proactive-but-not-overwhelming graph curation.



## Updated March 16, 2026
New interest domains added: Philosophy (stoicism, existentialism, ethics, philosophy of mind) and Comics & Superhero Universes (Marvel, DC). Both are now active nodes in the graph with edges connecting them across all major domains.',NULL,NULL,'2026-03-16T10:36:02.509Z','2026-03-16T23:51:14.459Z','{}','Bradd

Identity anchor — Bradd is a game developer, Rocket League YouTuber, rapper/poet, and AI enthusiast building a second brain to synthesize research, predict trends, and generate new insights.

Active domains: Godot game development, Rocket League YouTube content, rap and creative writing, AI/tech research, mental health and wellness. Goal: use the knowledge graph to compile information, surface connections, and form new thoughts. Style: mix of executor, note-taker, and connector. Prefers concise+direct but also conversational. Wants proactive-but-not-overwhelming graph curation.',NULL,NULL,NULL,'not_chunked');
INSERT OR IGNORE INTO nodes (id,title,description,notes,link,event_date,created_at,updated_at,metadata,chunk,embedding,embedding_updated_at,embedding_text,chunk_status) VALUES (2,'Godot Game Development','Active project — Bradd is building games with the Godot engine and is open to exploring other game development avenues. Central hub for game dev research, tutorials, and project progress.','Engine: Godot. Open to other platforms/engines as well. Relevant research areas: game mechanics, shaders, GDScript, AI-assisted game dev tools, indie publishing.',NULL,NULL,'2026-03-16T10:36:08.958Z','2026-03-16T10:36:08.958Z','{}','Godot Game Development

Active project — Bradd is building games with the Godot engine and is open to exploring other game development avenues. Central hub for game dev research, tutorials, and project progress.

Engine: Godot. Open to other platforms/engines as well. Relevant research areas: game mechanics, shaders, GDScript, AI-assisted game dev tools, indie publishing.',NULL,NULL,NULL,'not_chunked');
INSERT OR IGNORE INTO nodes (id,title,description,notes,link,event_date,created_at,updated_at,metadata,chunk,embedding,embedding_updated_at,embedding_text,chunk_status) VALUES (3,'Rocket League YouTube Channel','Active project — Bradd runs a YouTube channel focused on Rocket League content. Hub for content strategy, video ideas, audience growth, and game analysis.','Platform: YouTube. Game focus: Rocket League. Relevant areas: content creation, video editing, SEO, audience engagement, competitive meta analysis.',NULL,NULL,'2026-03-16T10:36:10.561Z','2026-03-16T10:36:10.561Z','{}','Rocket League YouTube Channel

Active project — Bradd runs a YouTube channel focused on Rocket League content. Hub for content strategy, video ideas, audience growth, and game analysis.

Platform: YouTube. Game focus: Rocket League. Relevant areas: content creation, video editing, SEO, audience engagement, competitive meta analysis.',NULL,NULL,NULL,'not_chunked');
INSERT OR IGNORE INTO nodes (id,title,description,notes,link,event_date,created_at,updated_at,metadata,chunk,embedding,embedding_updated_at,embedding_text,chunk_status) VALUES (4,'Rap & Creative Writing','Active creative practice — Bradd writes rap and poetry. Hub for lyrical ideas, writing techniques, wordplay, flows, and creative inspiration.','Formats: rap, poetry. Themes likely intersect with personal experience, mental health, and broader social/cultural ideas. AI tools may augment creative process.',NULL,NULL,'2026-03-16T10:36:12.659Z','2026-03-16T10:36:12.659Z','{}','Rap & Creative Writing

Active creative practice — Bradd writes rap and poetry. Hub for lyrical ideas, writing techniques, wordplay, flows, and creative inspiration.

Formats: rap, poetry. Themes likely intersect with personal experience, mental health, and broader social/cultural ideas. AI tools may augment creative process.',NULL,NULL,NULL,'not_chunked');
INSERT OR IGNORE INTO nodes (id,title,description,notes,link,event_date,created_at,updated_at,metadata,chunk,embedding,embedding_updated_at,embedding_text,chunk_status) VALUES (5,'AI & Tech Trends','Primary research domain — Bradd actively follows AI developments (especially Claude/Anthropic) and broader tech trends. Hub for synthesizing how AI tools apply across his other domains.','Primary focus: Claude AI, Anthropic. Broader: LLMs, AI-assisted development, generative tools for creative work, AI in game dev. Goal: predict trends and apply emerging tools.',NULL,NULL,'2026-03-16T10:36:15.599Z','2026-03-16T10:36:15.599Z','{}','AI & Tech Trends

Primary research domain — Bradd actively follows AI developments (especially Claude/Anthropic) and broader tech trends. Hub for synthesizing how AI tools apply across his other domains.

Primary focus: Claude AI, Anthropic. Broader: LLMs, AI-assisted development, generative tools for creative work, AI in game dev. Goal: predict trends and apply emerging tools.',NULL,NULL,NULL,'not_chunked');
INSERT OR IGNORE INTO nodes (id,title,description,notes,link,event_date,created_at,updated_at,metadata,chunk,embedding,embedding_updated_at,embedding_text,chunk_status) VALUES (6,'Mental Health & Wellness','Personal focus area — Bradd actively studies and practices mental health improvement and physical optimization. Hub for research on mindset, habits, body, and mind practices.','Areas: mental health strategies, physical fitness, mindset work, habit formation, emotional regulation, holistic wellness approaches.',NULL,NULL,'2026-03-16T10:36:17.277Z','2026-03-16T10:36:17.277Z','{}','Mental Health & Wellness

Personal focus area — Bradd actively studies and practices mental health improvement and physical optimization. Hub for research on mindset, habits, body, and mind practices.

Areas: mental health strategies, physical fitness, mindset work, habit formation, emotional regulation, holistic wellness approaches.',NULL,NULL,NULL,'not_chunked');
INSERT OR IGNORE INTO nodes (id,title,description,notes,link,event_date,created_at,updated_at,metadata,chunk,embedding,embedding_updated_at,embedding_text,chunk_status) VALUES (7,'Build your own Knowledge Base in 10 mins (FREE & Open Source)','By rah app: Build your own Knowledge Base in 10 mins (FREE & Open Source)','Video by rah app','https://www.youtube.com/watch?v=IA02YB8mInM&t=1348s

This is the video where I found Ra-h os',NULL,'2026-03-16T10:38:51.863Z','2026-03-16T10:38:51.863Z','{"source":"youtube","video_id":"IA02YB8mInM","channel_name":"rah app","channel_url":"https://www.youtube.com/@try_rah_app","thumbnail_url":"https://i.ytimg.com/vi/IA02YB8mInM/hqdefault.jpg","transcript_length":31525,"total_segments":702,"language":"en","extraction_method":"typescript_youtube_transcript_plus_en","ai_analysis":"Fallback description used","summary_origin":"metadata_description","refined_at":"2026-03-16T10:38:51.848Z"}','[1.5s] Everything I am about to share is fully
[5.6s] open source. It''s free. You can do what
[7.4s] you want with it. Promise that this is
[9.7s] not an AI slot coded product pitch. So
[15.1s] here''s the idea. Uh everybody who is
[18.3s] building or using or interacting with AI
[20.9s] should be building their own external
[25.0s] context. So, we''re at a point where if
[27.5s] you give really good context to these
[30.6s] tools, to these language models, it can
[33.2s] really help you do incredible things as
[38.2s] a a thinking partner, as a research
[39.9s] assistant, as a coding agent. Uh, and if
[44.3s] you''re lazy, which most people are,
[47.1s] they''re going to make you incredibly
[48.3s] stupid. So I think that building your
[51.0s] own externalized context is the best way
[53.2s] to use these tools more effectively.
[56.1s] What do I mean by this? Building your
[57.7s] own external context. All of your
[60.5s] knowledge, all of your interaction that
[63.0s] you''re having, all of these interactions
[64.4s] that you''re having with language models
[66.6s] is likely valuable context if it''s
[70.2s] organized in the in the right way. So
[73.1s] currently for most of us this kind of
[75.2s] knowledge or context is fragmented
[77.0s] across different platforms and devices.
[79.0s] You might be using grock or chat and
[81.3s] claude and
[83.5s] uh whatever else all of these different
[85.8s] tools these different language models
[87.4s] and then you''re kind of in a halfass way
[90.2s] storing that knowledge either in
[92.8s] projects within these tools or in
[95.3s] separate software and tools notes and uh
[98.6s] notion and Rome and Obsidian.
[101.7s] you really need to be more thoughtfully
[105.2s] uh organizing,
[107.0s] connecting, collecting your context in a
[109.8s] way that both you and increasingly these
[112.0s] agents that you''re working with can
[113.9s] leverage.
[115.8s] So what this is, I''m going to give you a
[119.2s] template that I''ve used for myself and
[121.7s] show you how to set that up. I think
[123.6s] that this is the best and most
[126.6s] appropriate way to store and organize
[130.6s] your external context. I''m open to
[132.2s] hearing some push back. Uh I''ve tried
[135.3s] all of the different approaches.
[137.8s] So, you know, notion and Rome and uh
[143.9s] even more recently Notebook LM and uh
[147.6s] Obsidian. I love Obsidian with Claude
[150.2s] Code. I just don''t think that any of
[152.6s] these are the right abstraction moving
[155.3s] forward.
[157.2s] Uh I''ve spoken more about why I think
[160.3s] that Obsidian and CL code is great, but
[162.2s] it''s not the right approach. And it
[163.8s] basically just boils down to this idea
[166.6s] that if you think you''re increasingly
[168.2s] going to be interfacing with your
[169.9s] knowledge and with your context through
[172.2s] AI, then you should be building a system
[173.9s] that''s appropriate for them and not
[177.7s] trying to sticky tape after the fact
[180.7s] solutions
[182.2s] that do this. And a simple local
[186.2s] relational database has to be the best
[188.6s] abstraction that we have to do this. Uh
[191.8s] and it''s also because if you''re actually
[194.2s] doing a good job externalizing your
[196.0s] context,
[197.8s] uh the connections between things that
[199.9s] exist in that context graph are just as
[202.9s] important as the things themselves. And
[204.6s] a relational database allows you to do
[206.1s] this to create a more robust separate
[209.0s] table where these connections exist and
[212.8s] have some kind of semantic
[215.0s] identification so that the language
[216.6s] models or the agents that you''re working
[218.3s] with are able to really help you build
[221.6s] uh and enrich that that context graph.
[224.4s] So that was my rant. Uh, I''m basically
[227.8s] going to explain this in a way that
[230.5s] somebody with no technical experience,
[231.9s] somebody who hasn''t used GitHub or open
[234.8s] source software can follow along. It''s
[237.9s] really easy now that we have these
[239.4s] tools. I''m assuming that you''re going to
[241.3s] be using some coding agent. I''m going to
[243.2s] use Claude Code, but you could also use
[246.1s] Open Code. I''ve got it hooked up to Open
[247.8s] Code and Cursor and Codeex. You can use
[250.3s] any of these tools.
[254.6s] Okay. So, I''m going to run my CL code
[260.4s] here. This is the repo. All you need to
[263.0s] know about this is when you when you
[267.0s] clone it, it''s just like you''re
[268.1s] downloading a traditional piece of
[270.1s] software. It''s going to go onto your
[272.6s] device and you''re going to have that
[275.1s] database that I''m talking about. It''s
[276.6s] going to seed. There''s a script that''s
[278.3s] going to seed and generate a local
[282.7s] SQLite database. It''s just one file and
[285.5s] that''s going to exist in the library.
[287.2s] You never even have to open up that file
[289.0s] yourself and this is going to have those
[291.4s] relational tables that I spoke about.
[293.6s] And it''s also when you clone this repo
[296.4s] going to uh install the dependencies and
[299.9s] basically install a simple TypeScript
[302.2s] front end that I''m going to show you
[304.1s] that you can use to interact with that
[306.1s] data
[308.4s] or interact with your knowledge or your
[310.6s] context I should say.
[313.1s] Okay. Okay. Now, the great thing about
[314.8s] these coding agents as well now is
[319.0s] you can just grab this URL and point
[322.0s] Claude to whatever coding agent you''re
[323.6s] using directly at the repo and it''s
[326.6s] going to be able to install it for you.
[327.9s] It''s going to take away any of the
[332.0s] nalia overwhelming stuff
[335.7s] that would normally come with running
[337.6s] open source software. So, this is what
[340.2s] I''m doing here. What I just explained,
[341.8s] I''m going to clone the repo. is just
[343.1s] basically going to install the
[345.5s] dependencies which is the extra code
[347.5s] that I need to be able to run this
[349.2s] application locally on my device.
[354.0s] These are those dependencies that I
[355.6s] spoke about. You can have a quick look
[357.5s] through the readme. Uh but this is set
[360.5s] up in a way that the coding agent you''re
[362.6s] working with is going to have the
[364.4s] information it needs to be able to
[367.4s] uh clone and run this app locally on
[369.6s] your device. So this part here, the
[371.8s] rebuild better SQL light, this is
[373.6s] basically where the database
[377.1s] is going to be
[379.6s] uh installed on your device. Now the
[382.8s] application is going to exist on your
[384.5s] home directory. It''ll be really easy to
[386.0s] find. The database itself won''t be easy
[388.6s] to find. You never actually need to open
[390.0s] it up. If you want to, you can work out
[391.8s] how to do that. Go to Google. Basically,
[393.9s] Apple is going to store it in uh a
[397.1s] library folder that''s kind of hard to
[399.0s] access. it''s made hard to access because
[401.5s] they put in there the kind of stuff that
[404.6s] if you with it, it could break the
[406.2s] applications on your on your Mac. Um, so
[410.0s] it''s good that it exists in there. You
[411.8s] never have to to to go in there and find
[414.5s] it, but you can if you want. And it''s a
[415.9s] single SQLite file. This is the script
[418.7s] that''s going to load
[421.0s] um those tables. All right, great. So
[425.4s] that''s now running.
[427.7s] Now, let me just show you. I could come
[429.2s] here and
[432.6s] find the app. So the app will be easy to
[434.5s] find. It''ll be here just like any other
[436.6s] application on your device. It''s open
[438.1s] source now. So you can modify it. But I
[440.3s] would say stick to the structure for now
[441.9s] for the start.
[444.3s] And uh I''m going to come here and I can
[451.0s] jump into the directory. So this is I''m
[452.9s] just pointing to that folder that I just
[455.5s] showed you which is the application
[456.7s] itself. And then I can just say npm
[459.0s] rundev and it''s going to launch the
[461.0s] application locally on my device. That
[463.6s] easy. And now if I come to the browser,
[467.4s] this is my knowledge base. It''s going to
[469.7s] be an empty database.
[473.0s] Great.
[475.3s] So you could run that. You could ask
[477.3s] claude code to run that for you. You can
[479.2s] run this command and have it running
[480.5s] persistently in the background. Uh it''s
[483.0s] basically going to always be available
[484.6s] here. and it doesn''t need to be running
[486.3s] for your agent to be able to interact
[487.8s] with the database. It''s just nice for
[489.0s] you to have open here on your device
[490.9s] whenever you want.
[494.6s] Okay, so I''m going to just show you
[496.1s] quickly if you the muggle human
[498.6s] interacting with your context want to
[500.5s] add stuff, you can do so here. Uh the
[503.1s] system is set up so that it can ingest
[504.7s] content really easily. So here I''m going
[507.2s] to grab this conversation with
[509.4s] Steinberger and Lex Friedman and I can
[511.9s] drop the URL here. I can also put
[514.2s] anything else in there that I want. I
[515.7s] can add a note or an idea or I can drag
[517.8s] a PDF
[520.2s] and it''s going to appear here in the
[521.9s] database
[526.5s] as a node. So this is going to take a
[528.6s] little bit because when this is a long
[530.8s] conversation and we can see here the
[532.7s] transcript
[534.4s] um and it''s going to be chunked and
[536.2s] embedded which I can explain later but
[538.0s] basically this exists as a single node
[540.4s] now in the knowledge base or in the
[542.6s] context graph whatever you want to call
[544.2s] it.
[545.7s] I could also grab just to show you an
[547.3s] article here
[549.8s] uh or a tweet whatever you want to add
[552.0s] into the thing. This is how you can add
[553.6s] this stuff in manually here.
[560.2s] Great. So now I''m going to have when
[561.9s] this loads into the knowledge base, I''m
[564.2s] going to have both of those notes in
[566.3s] there. Now something that I forgot.
[568.2s] I should have explained this at
[569.7s] the start. Let me move this. Is when you
[572.4s] first download the claim the repo and
[576.6s] open it up, it''s probably going to
[578.1s] prompt you for an API key. If not, you
[580.7s] can come here and put it in. So you
[583.0s] don''t have to have this to be able to
[585.1s] use the device or to be able to use the
[587.8s] context graph, but you want to add it.
[590.2s] So go and get an OpenAI API key. It
[593.0s] literally costs like cents per day. I
[595.4s] use it every day. And what that API key
[598.1s] does is there''s just a few pipelines
[599.7s] that are running in the background that
[601.4s] will enhance the content that you''re
[602.8s] adding. For example, if I''m adding this
[605.0s] podcast here, uh it''s going to use the
[608.6s] OpenAI key to chunk and embed that
[610.8s] entire transcript into the knowledge
[613.4s] base. And then it also going to use like
[615.9s] a cheap model. I think it''s GBT4 mini,
[619.0s] which is going to run in the background
[620.2s] and just enhance your data as it''s
[621.8s] coming in and apply these dimensions. Uh
[624.6s] I didn''t ask me for my API key cuz I''ve
[626.7s] already got it stored in the global
[628.0s] config, but you can go and get an OpenAI
[630.8s] API key. It''s going to cost you cents at
[633.8s] most per day to have that running in the
[636.6s] background there. And it''s going to be
[637.5s] worth it because it''s going to enhance
[639.1s] and clean up and organize your data,
[640.8s] which is good for lazy people.
[644.7s] Okay, so the app is pretty intuitive.
[647.3s] You should get the hang of it. You
[648.3s] basically have these panes that exist
[650.2s] here and they''re just different ways of
[651.8s] visualizing your data. There''s a full
[653.9s] database view, so you can see the actual
[656.2s] table. There''s a map or a graph that''s
[659.1s] going to display your nodes and how they
[661.9s] connect together.
[663.9s] And there''s a dimension view. So
[665.4s] dimensions are basically just one simple
[667.7s] layer of organization that exist as
[670.0s] folders. And the system can help
[672.2s] organize the data as it comes into your
[674.2s] context graph into these folders. If you
[676.6s] want to learn more about that, I''ve
[678.1s] created heaps of documentation which
[679.4s] I''ll link to.
[682.0s] Okay, but now for the fun stuff. So, the
[686.1s] whole idea of this open- source,
[688.6s] the reason that I''m doing this and uh
[691.4s] it''s cuz I don''t want to be greedy. in
[692.6s] order to make open source tools, but
[693.9s] it''s also the way that things are
[695.1s] changing, which is that a lot of people
[696.6s] I think are going to be using clawed
[698.8s] code or these coding harnesses and
[701.1s] rather than having a monolithic piece of
[704.2s] software
[705.7s] um where the agent lives in the tool and
[709.2s] and you pay for that, I think that
[711.5s] people are going to be using these
[712.5s] external tools and then interfacing
[715.8s] through them to write to their database.
[718.2s] So, what we''re going to set up here is
[720.5s] an MCP server. Now, this information is
[723.4s] all again listed in this readme
[726.5s] document, and your coding agent is going
[728.6s] to know exactly how to do this. So, I''m
[731.4s] going to come back to here and just say,
[733.4s] can you set up the MCB server?
[738.6s] So, I won''t go into any great depth on
[741.7s] what MCP is. You can go and read more
[743.8s] about that. Basically, it''s just a
[745.7s] standardized way that allows products or
[747.3s] services um to expose
[751.0s] that product or service to the user or
[754.4s] the agent in a uh in a standardized way.
[758.6s] So, I think people forget that it''s
[759.9s] really just designed for situations
[761.4s] where these existing products or
[762.8s] services
[764.6s] um want to scale and standardize the way
[766.9s] that users interact with those services.
[768.8s] So, for example, uh you might want to
[771.3s] connect your email to your agent or you
[774.0s] might want to plug into Salesforce and
[775.6s] it''s just a more consistent way for the
[777.0s] agent to be able to use tools to
[778.9s] interact with that service.
[783.0s] Uh what else do I want to say about
[784.8s] this?
[789.7s] So, I''d like to think that this way of
[791.6s] using MCP is a little bit more
[795.3s] interesting. It kind of flips the
[797.0s] situation
[798.9s] in that what you''re doing here is
[804.3s] um allowing Claude or whatever agent
[807.5s] you''re using to have a bridge directly
[810.4s] to your knowledge graph. And this is
[813.5s] kind of like giving Claude access to
[815.8s] your second brain, if you want to call
[817.4s] it that. and just basically allowing it
[821.4s] to continually read, search, add,
[824.7s] connect things um
[828.0s] directly between your interactions with
[829.7s] the coding agent or the agent that
[831.0s] you''re using and this this ontology or
[834.6s] this knowledge graph that you''re
[835.8s] building.
[849.4s] Okay. So when you install claude code or
[852.2s] whatever coding agent you''re using uh
[854.2s] it''s going to have a config file. So
[856.1s] when you all that''s happening when you
[859.0s] uh install this MCP server is the your
[865.6s] your claude code instance is basically
[868.2s] being updated with um
[872.2s] access to this server or this bridge
[874.9s] that is exposing some tools. It''s
[877.2s] basically just allowing whenever you
[879.5s] load claude claude code or whenever you
[881.5s] load your coding agent, it is being
[883.7s] injected with this information about
[886.0s] this bridge that exists between
[888.9s] itself and your knowledge graph. And the
[891.2s] way that these tools have been
[892.4s] configured
[893.9s] um is going to encourage the agent to be
[896.6s] continually reading and writing from
[898.1s] this knowledge graph for you. So it''s
[900.2s] going to be kind of ambiently building
[902.4s] your knowledge graph in the background
[904.7s] uh if you set things up correctly.
[906.8s] So, uh, I can come to here. I''m just
[909.2s] going to open up a new instance of
[911.3s] Claude Code to show you because this is
[912.8s] what you''ll have to do. You will install
[914.6s] the MCP server and then you just need to
[916.8s] reopen Claude code or restart Claude
[918.7s] Code and then uh that that MCP server
[923.1s] will be ready to check out. So, you can
[925.4s] come here now in MCP and then I''ve got a
[928.5s] few here, but this is the one we''re
[930.2s] talking about. So, this is the one that
[931.5s] will now be installed or added to the
[933.0s] config. And you can see the tools.
[936.0s] Now, most of these tools are going to be
[939.4s] pretty self-explanatory. They''re just
[941.8s] simple ways to interact with the
[944.2s] knowledge base. There''s like a SQL light
[946.2s] query tool. Um,
[949.4s] and all this other stuff here are just
[951.5s] tools that basically
[954.0s] have the have the schema of your
[957.6s] knowledge graph and the dimensions and
[959.7s] the folders that you''ve set in context.
[962.5s] So that if you say to RA or if you say
[964.8s] to sorry Claude code uh hey go and
[968.0s] research this thing for me then you can
[970.9s] easily add that thing into your
[972.8s] knowledge graph or into your context
[974.8s] graph in a way that uh claude code
[978.3s] understands how it''s formatted or how
[979.8s] those tables are structured.
[983.1s] So there''s two kind of things in here
[985.0s] that I just want to call out so which
[987.6s] we''ll speak about soon. Get context is a
[990.7s] tool that is basically going to allow
[992.8s] your agent to traverse your knowledge
[995.4s] graph and pull in interesting and
[998.2s] relevant things.
[1000.6s] So as you build your context graph,
[1003.8s] certain nodes or items that exist in
[1005.8s] that context graph are going to
[1007.1s] accumulate more connections. Um and that
[1011.0s] indicates to the agent that these are
[1013.4s] things that might be hub nodes or things
[1015.1s] that are more important for context. And
[1018.1s] so when you''re in embarking on any uh
[1021.8s] mission with Claude Code or whatever
[1023.3s] coding agent you''re using, whether
[1024.5s] that''s research or coding or building an
[1027.7s] application, it''s going to be able to
[1030.1s] pull in context and traverse that graph
[1032.6s] in a really effective way to be able to
[1034.9s] pull in relevant context or context that
[1037.5s] would be relevant to the thing that
[1038.7s] you''re doing at the time. and it just
[1041.4s] paints like a nicer ontology rather than
[1044.5s] having things stored in a single memory
[1048.2s] markdown file. The idea here is the
[1050.0s] things that you''re working on, your
[1051.4s] context, your ideas, your belief, your
[1053.5s] memory, this is all fluid and changing
[1056.1s] and evolving over time. And by just
[1058.1s] giving the agent access to your
[1061.0s] knowledge graph, pending you have spent
[1064.1s] some time thoughtfully organizing it,
[1065.6s] it''s going to be able to pull in a very
[1067.0s] efficient and very effective context.
[1072.6s] So now I can just test it out. I can say
[1078.6s] what''s
[1080.2s] in my knowledge graph.
[1087.7s] And you can see that it''s going to Oh,
[1090.8s] there''s a bit of overlap here because
[1092.5s] I''ve installed multiple MCP servers. I''m
[1094.6s] just going to say check in RA.
[1111.8s] Great. So, it''s found
[1114.3s] it''s found the two things that we just
[1115.8s] added into the graph before that I can
[1117.7s] see here, the article and the YouTube
[1119.8s] video. I can say
[1122.3s] um create a relevant
[1126.8s] connection between these two
[1132.3s] nodes
[1137.2s] and it''s going to find the create edge
[1139.0s] tool.
[1142.6s] And yeah, one thing I didn''t mention
[1143.9s] here is there''s also guides which act as
[1145.8s] skills and basically workbooks that
[1147.7s] explain to the agent how you want to
[1150.2s] structure your knowledge graph. So, we
[1152.6s] can read from those to understand the
[1154.6s] correct format. Um, and maybe these
[1156.6s] things are specific to how you would
[1158.4s] like to structure your context. Okay, so
[1161.8s] now I just created that edge. Let''s go
[1164.2s] and have a look. I can open this up,
[1166.7s] this node, and there should be one edge
[1168.6s] here now. There it is. Open. There we
[1170.8s] go. Exemplifies a kind of viral
[1172.6s] breakthrough story. Yeah.
[1176.0s] Okay, great. So, the whole idea is just
[1177.7s] basically to use these tools to reduce
[1179.7s] friction to build yourself this more
[1182.9s] enriched context graph. So here''s
[1185.1s] another example.
[1187.7s] Hey, can you go and do some more
[1189.9s] research on Peter Steinberger and open
[1192.6s] claw and add this as a separate node for
[1194.8s] me to follow up in RA.
[1203.8s] And so now cloud code can go off and do
[1205.7s] some web search and it''s going to come
[1207.1s] back and start creating this new node in
[1211.5s] my context graph to follow up later. I
[1213.9s] might also tell it that I''m trying to
[1215.4s] build out this project. So that the the
[1218.4s] goal here is just to provide as much
[1221.2s] valuable context as possible
[1224.8s] and start creating connections which is
[1228.8s] not easy. You got to really think hard
[1230.3s] about how these different parts of your
[1232.0s] ontology connect and which are the most
[1236.1s] important ways what are the most
[1238.2s] important nodes or pieces of information
[1240.4s] or pieces of context. How do they
[1242.6s] connect to the other things in your
[1243.8s] knowledge graph? And how can this be
[1245.6s] structured in a way that can be
[1246.9s] leveraged by AI so that when you go back
[1248.9s] to do a new task or a new project,
[1253.0s] uh, the system has the context that it
[1255.8s] needs to really help you do a good job.
[1267.9s] Okay, so I need to stop it.
[1272.0s] That''s enough, mate.
[1275.9s] Add the node.
[1288.8s] Okay. So, yeah, you can see here it''s
[1291.2s] automatically added the edge the
[1292.6s] connection without asking me, without me
[1294.9s] telling it to, which is pretty cool.
[1297.7s] And so as you build this graph more
[1299.9s] thoughtfully, it gets better at doing
[1301.0s] this. So now I can come back to the feed
[1303.0s] and we have this third node that now
[1305.9s] exists in the knowledge graph.
[1309.4s] Wonderful with the edge.
[1313.3s] Okay. So I''m just going to give like a
[1315.0s] really highle uh overview of the
[1318.6s] architecture and the schema and yeah the
[1322.1s] UX. There''s documentation on this and
[1324.4s] it''s pretty self-explanatory.
[1326.6s] hopefully. So this will be pretty quick
[1329.2s] and pretty high level. So everything in
[1332.1s] here is just a different way to view or
[1335.8s] augment your data. So the feed I think
[1339.1s] will show up by default. And these are
[1342.1s] your nodes. So nodes are like the atomic
[1344.8s] units of context that exist within your
[1347.1s] knowledge graph. Could be an idea, an
[1349.4s] insight, a memory, an event, a person or
[1352.5s] an entity, a podcast, an article, any of
[1356.2s] these things. They all exist as
[1357.7s] individual nodes within your context
[1360.5s] graph. Let''s focus on an individual node
[1363.8s] here. So the important the important
[1366.3s] considerations here are the description.
[1369.4s] Now the description needs to be I I
[1372.6s] really need to emphasize this models
[1376.0s] need verbose
[1378.3s] explanation of what things are in very
[1380.9s] simple terms. Right? So the system has
[1382.7s] been set up to try to do this. So any
[1386.0s] item that goes into the context graph
[1388.8s] should have a very specific description
[1391.3s] the most high level abstraction of what
[1393.5s] the thing is. So this is a podcast.
[1397.0s] uh this is why it''s important and
[1398.2s] ideally why it''s important for you. So
[1400.6s] that''s a description. There''s notes
[1402.8s] which you can edit, you can update, you
[1405.0s] can add in your own notes.
[1407.3s] There''s the edges which are the
[1408.6s] connections also really important and
[1411.1s] the connections between
[1413.4s] nodes should have really good
[1415.7s] explanations and the system should be
[1417.6s] able to infer the type of connection
[1419.4s] that that is why these two things
[1421.3s] connect. This is really important
[1423.3s] because it allows for this dynamic
[1425.2s] traversal for context.
[1428.3s] And then there''s the source. So in some
[1430.2s] cases, if it''s something really big,
[1433.4s] uh, like a podcast with a long
[1435.2s] transcript, the transcript is
[1436.5s] automatically going to be pulled into
[1438.8s] here into the source, which then gets
[1441.4s] chunked and embedded in a separate
[1442.8s] table. You never have to see that
[1444.1s] separate table. Basically that is just
[1446.2s] for longer items to allow um the model
[1450.4s] that you use to use a vector embedding
[1452.5s] search uh to to search over longer
[1457.0s] um
[1458.6s] longer research items for example. In
[1460.9s] some cases it might just be a simple
[1463.0s] note and then that note will also exist
[1465.1s] in the source and in the in the chunk
[1467.0s] table. And then you have these
[1469.3s] dimensions right? So these dimensions
[1470.6s] are just a simple one layer of
[1475.4s] organization.
[1477.8s] Uh this is how you want to organize your
[1479.8s] data. You can add new dimensions and
[1481.6s] then you should always add dimension
[1483.3s] description and that is going to inform
[1487.4s] the model
[1489.5s] uh of what belongs in that folder or
[1491.5s] what belongs in that dimension. So when
[1493.1s] you add new stuff, it can look at it''s
[1495.1s] always going to look at the description
[1496.3s] and say, "Ah, this looks like a podcast
[1498.6s] or this looks like an idea or this looks
[1500.2s] like a preference or a memory or a
[1502.8s] project." You create new ones here and
[1505.1s] you can lock the ones that are most
[1506.6s] important to you. Uh add the description
[1509.0s] because the description allows the model
[1511.3s] to know what it''s adding and how it''s
[1514.2s] going to organize your stuff into these
[1517.0s] folders. I want to emphasize here though
[1518.9s] that by by design
[1522.6s] there''s not much in the way of
[1524.2s] hierarchical organization. There''s not
[1525.9s] folders within folders because the heavy
[1528.2s] lifting should be done by these edges
[1530.6s] that you create more thoughtfully why
[1532.2s] things connect together
[1534.5s] and the description that you''ve listed
[1536.2s] for the individual
[1538.5s] uh nodes that have been added into your
[1540.2s] context graph. Okay, so simple
[1543.0s] structure. Now, the last two things to
[1544.7s] mention are the context, which we spoke
[1547.8s] about briefly before with the MCP tool
[1550.6s] that allows the agent that you''re
[1552.4s] working with to pull in context in a
[1554.0s] fluid way. So, basically, you''re going
[1556.5s] to have uh this context option here. And
[1562.0s] what this is going to do is it''s going
[1563.8s] to show your most highly edged nodes. So
[1568.4s] this all this is is the stuff that
[1572.1s] you''re adding into your context graph
[1575.1s] will have connections. The connections
[1576.7s] are really important as we mentioned and
[1579.9s] the nodes that have the most connections
[1582.2s] are going to appear to the agent as the
[1584.9s] ones that are most contextually
[1586.6s] important for you. So what I like to do
[1589.4s] in my fully built out uh context graph
[1593.1s] is to have these hub nodes that reflect
[1595.0s] kind of the big projects that I''m
[1597.2s] working on uh areas of interest things
[1600.5s] that I''m I''m building and they have
[1602.8s] hundreds and even in some cases
[1604.2s] thousands of connections right and so
[1606.2s] when I start using one of these agents
[1609.0s] it has that awareness that this is the
[1610.9s] stuff that''s most important to me and it
[1612.7s] can then traverse out from those hub
[1614.6s] nodes uh by default if you are
[1618.2s] thoughtfully adding stuff and connecting
[1620.2s] stuff, the information in the context
[1622.8s] graph that you connect the most will go
[1625.4s] to the top of of the graph and appear
[1630.1s] and appear to the agent that in that
[1631.8s] way. Now, when you''ve built this out,
[1633.2s] you can actually use this
[1635.7s] graph view here and it will cluster the
[1639.8s] most edged nodes toward the middle of
[1642.1s] the graph. And that''s what that''s
[1644.6s] basically what the agent is going to
[1646.6s] see. What''s a representation of what the
[1648.6s] agent is going to see? It''s going to see
[1650.1s] those most highly edged nodes first and
[1652.6s] then it''s going to be able to traverse
[1654.0s] out.
[1656.9s] And then the last thing is just these
[1658.2s] guides. So
[1661.2s] guides are like skills. You may or may
[1663.2s] not be familiar with skills, but the
[1664.7s] idea here is you can just store raw
[1668.6s] information in markdown and have it
[1671.8s] properly formatted with some front
[1673.3s] matter. And that''s all that is doing is
[1676.4s] when the model or the agent that you''re
[1679.1s] working with uh is trying to do
[1681.3s] something for you, you ask it to do
[1682.5s] something, it''s always going to be able
[1684.2s] to refer to these guides if it doesn''t
[1685.8s] know what to do. Okay. So here I''ve
[1690.0s] prepackaged the app with these guides
[1692.9s] that you''ll see here which are basically
[1694.6s] just foundational
[1696.6s] universal
[1698.6s] uh information that the the agent can
[1701.8s] use or refer to when it''s organizing
[1704.0s] your data. So it can look in here for
[1706.4s] the schema to see how your database is
[1708.9s] structured if you want to change things.
[1710.6s] It can look in there for your
[1711.8s] preferences as to how you like to store
[1714.2s] or enrich or organize data. And then
[1717.4s] it''s just also got some information
[1718.7s] there on the philosophy behind the
[1721.0s] structure of this of this context graph,
[1723.0s] how it can traverse the context graph to
[1725.3s] pull in uh valuable information when it
[1727.7s] needs to. You can do anything in here
[1729.6s] though, right? Like I have guides that
[1731.0s] help me create audio debriefs. I have
[1733.7s] guides that will automatically pull in
[1737.0s] uh res research and resources that I
[1739.7s] like and um build me interesting
[1742.1s] flashcards. all this kind of thing you
[1743.9s] can do.
[1747.0s] So
[1748.6s] that''s basically it. Uh if you if you''re
[1752.5s] going to give this a try, please come
[1754.6s] and join the discord and yeah, give me a
[1757.8s] star on GitHub. I currently have zero
[1760.6s] stars. And um
[1764.2s] yeah, contribute contributions would be
[1767.1s] really really appreciated. And overall,
[1770.3s] I just love to start building this out
[1772.2s] and understanding how different people
[1773.8s] want to use this and build their context
[1775.5s] graph and hopefully get some feedback
[1777.0s] and be able to evolve the the product
[1780.2s] and the framework. Ciao.',NULL,NULL,NULL,'not_chunked');
INSERT OR IGNORE INTO nodes (id,title,description,notes,link,event_date,created_at,updated_at,metadata,chunk,embedding,embedding_updated_at,embedding_text,chunk_status) VALUES (8,'grocery-tracker — Project Overview','Private Flask + SQLite app at C:/Projects — tracks grocery prices via Kroger API, plans weekly meal budgets, manages pantry/recipes, with full AI recipe generation, ratings, and Chrome extension.','**Stack:** Python/Flask backend, SQLite (via better-sqlite3 pattern but using sqlite3 stdlib), Jinja2 HTML templates, vanilla JS frontend, deployed on Railway.

**Key integrations:**
- Kroger API — product search, pricing, aisle locations
- Anthropic Claude (claude-sonnet-4-20250514) — ingredient extraction from meal names and recipe pages

**Modules:**
- `app.py` — Flask app entry, blueprint registration, route pages
- `database.py` — all SQLite CRUD helpers (recipes, pantry, price_history, budget_plans, budget_meals, quick_list, purchase_frequency)
- `routes/search.py` — Kroger token mgmt, ingredient parsing via Claude, product search with ThreadPoolExecutor
- `routes/budget.py` — weekly meal budget planner, shopping list generation
- `routes/quicklist.py` — quick shopping list with quantity tracking and purchase frequency
- `routes/recipes.py` — recipe save/delete/rename, AI ingredient extraction
- `routes/pantry.py`, `routes/history.py`, `routes/data.py` — pantry mgmt, price history, data import/export
- `grocery-extension/` — Chrome extension that extracts recipes from any webpage and POSTs to Railway app

**Deployment:** Railway at https://web-production-fcb56.up.railway.app
**DB file:** controlled by DATA_DIR env var, defaults to local `grocery.db`
**Schema migrations:** versioned via `schema_version` table



--- UPDATE 2026-03-17 ---
**New Claude AI features added (Phase 2):**
- `routes/search.py` — `get_full_recipe(meal_name, servings)`, `get_full_recipe_from_text(page_text)`, `get_recipe_variations(meal_name, type)`, `get_ingredient_substitution(ingredient, meal_name)`
- New routes: `POST /generate-full`, `POST /api/recipe/variations`, `POST /api/recipe/substitutions`
- `routes/recipes.py` — `POST /extract-recipe-full` (full extraction with instructions), `POST /api/recipes/save-ai`, `POST /api/recipes/<id>/rate`, `POST /api/recipes/<id>/tags`
- `routes/budget.py` — `POST /api/budget/meal/from-recipe/<recipe_id>` (price + add saved recipe to budget plan)

**Frontend (index.html) changes:**
- Servings input next to meal name
- ✦ button now calls `/generate-full` — shows full recipe panel with instructions, dietary flags, tags, variation buttons, Save button
- Swap modal now has both Kroger alternatives + Claude AI substitution suggestions
- Variation modal (Vegetarian / Budget / Under 30 Min)

**Frontend (recipes.html) changes:**
- Source badges (AI vs Web)
- Star ratings (click to rate, stores rating + notes)
- Dietary flag badges
- Tags as chips
- Collapsible instructions panel
- Filter bar: All / AI Generated / From Web / Rated / Vegetarian / Vegan / Gluten-Free
- 📅 button to add recipe directly to budget plan day','https://github.com/Misfit8/grocery-tracker',NULL,'2026-03-16T11:13:12.676Z','2026-03-17T01:48:08.091Z','{}','grocery-tracker — Project Overview

Private Flask + SQLite app deployed on Railway that tracks grocery prices via the Kroger API, plans weekly meal budgets, manages pantry/recipes, and includes a Chrome extension for recipe extraction.

**Stack:** Python/Flask backend, SQLite (via better-sqlite3 pattern but using sqlite3 stdlib), Jinja2 HTML templates, vanilla JS frontend, deployed on Railway.

**Key integrations:**
- Kroger API — product search, pricing, aisle locations
- Anthropic Claude (claude-sonnet-4-20250514) — ingredient extraction from meal names and recipe pages

**Modules:**
- `app.py` — Flask app entry, blueprint registration, route pages
- `database.py` — all SQLite CRUD helpers (recipes, pantry, price_history, budget_plans, budget_meals, quick_list, purchase_frequency)
- `routes/search.py` — Kroger token mgmt, ingredient parsing via Claude, product search with ThreadPoolExecutor
- `routes/budget.py` — weekly meal budget planner, shopping list generation
- `routes/quicklist.py` — quick shopping list with quantity tracking and purchase frequency
- `routes/recipes.py` — recipe save/delete/rename, AI ingredient extraction
- `routes/pantry.py`, `routes/history.py`, `routes/data.py` — pantry mgmt, price history, data import/export
- `grocery-extension/` — Chrome extension that extracts recipes from any webpage and POSTs to Railway app

**Deployment:** Railway at https://web-production-fcb56.up.railway.app
**DB file:** controlled by DATA_DIR env var, defaults to local `grocery.db`
**Schema migrations:** versioned via `schema_version` table',NULL,NULL,NULL,'not_chunked');
INSERT OR IGNORE INTO nodes (id,title,description,notes,link,event_date,created_at,updated_at,metadata,chunk,embedding,embedding_updated_at,embedding_text,chunk_status) VALUES (9,'grocery-tracker — routes/search.py (Kroger + Claude)','Core search route — authenticates with Kroger OAuth, uses Claude to parse meal names into ingredients, then fetches cheapest products in parallel via ThreadPoolExecutor.','**Kroger auth:** client_credentials flow, token cached in module-level globals with expiry check.

**Claude usage:**
- `get_ingredients_from_meal(meal_name)` — prompts claude-sonnet-4-20250514 to return bare ingredient names (no quantities)
- `get_ingredients_from_text(page_text)` — extracts ingredients from scraped webpage text; returns NONE if no recipe found

**Routes:**
- `POST /generate` — get ingredients for a meal name
- `POST /search` — search Kroger for cheapest product per ingredient (skips pantry items), records prices to DB
- `POST /quick-search` — direct product search by query string
- `POST /alternatives` — returns top-5 alternatives sorted by price

**Concurrency:** ThreadPoolExecutor(max_workers=8) for parallel Kroger API calls per ingredient.

**Env vars needed:** KROGER_CLIENT_ID, KROGER_CLIENT_SECRET, KROGER_LOCATION_ID, ANTHROPIC_API_KEY',NULL,NULL,'2026-03-16T11:13:23.397Z','2026-03-16T11:13:23.397Z','{}','import os, time, requests, anthropic
from concurrent.futures import ThreadPoolExecutor, as_completed
from flask import Blueprint, request, jsonify
from dotenv import load_dotenv
from database import db_load_pantry, db_record_prices',NULL,NULL,NULL,'not_chunked');
INSERT OR IGNORE INTO nodes (id,title,description,notes,link,event_date,created_at,updated_at,metadata,chunk,embedding,embedding_updated_at,embedding_text,chunk_status) VALUES (10,'grocery-tracker — database.py (SQLite schema + helpers)','All SQLite CRUD for grocery-tracker: recipes, pantry, price_history, budget_plans/meals, quick_list, with versioned migrations, new recipe metadata columns (v2), and JSON backup/restore.','**DB file:** `os.path.join(DATA_DIR, "grocery.db")` — DATA_DIR from env, defaults to cwd.

**Tables:**
- `recipes` (id TEXT PK, name, url, ingredients JSON, saved_at)
- `pantry` (id AUTOINCREMENT, item UNIQUE)
- `price_history` (ingredient, product_name, price, date — UNIQUE on ingredient+date)
- `budget_plans` (id, name, weekly_budget, is_active)
- `budget_meals` (id TEXT PK, plan_id FK, day, meal_name, ingredients JSON, priced_items JSON, total)
- `quick_list` (id, product_name, price, image, aisle, category, quantity, checked)
- `purchase_frequency` (product_name UNIQUE, add_count — upserted on every add)
- `schema_version` (version PK) — for migrations

**Migration pattern:** `MIGRATIONS` dict maps version int → SQL string. `_run_migrations()` applies any unapplied versions on startup.

**One-time JSON migration:** `migrate_from_json()` imports recipes.json, pantry.json, price_history.json then renames them to `.migrated`.

**Backup/restore:** `db_export_all()` / `db_import_all(data)` — full snapshot as dict (version=1).



--- UPDATE 2026-03-17: Migration v2 ---
**New recipe columns added via MIGRATIONS v2:**
- `instructions TEXT` — JSON array of step strings
- `dietary_flags TEXT DEFAULT ''[]''` — JSON array (vegetarian, vegan, gluten-free, dairy-free, nut-free, low-carb)
- `tags TEXT DEFAULT ''[]''` — JSON array of descriptive tags
- `rating INTEGER DEFAULT 0` — 1-5 star rating
- `notes TEXT DEFAULT ''''` — user notes on the recipe
- `servings INTEGER DEFAULT 4`
- `source TEXT DEFAULT ''extension''` — ''ai'' or ''extension''

**Migration system updated:** MIGRATIONS dict now supports list of SQL strings per version. `_run_migrations()` applies each stmt in a try/except to skip already-applied columns.

**New DB helpers:**
- `db_save_recipe()` — updated signature with optional instructions, dietary_flags, tags, servings, source
- `db_rate_recipe(recipe_id, rating, notes)`
- `db_update_recipe_tags(recipe_id, tags)`
- `db_load_recipes()` — returns all new fields, JSON-parses instructions/dietary_flags/tags',NULL,NULL,'2026-03-16T11:13:32.752Z','2026-03-17T01:48:17.498Z','{}','grocery-tracker — database.py (SQLite schema + helpers)

All SQLite CRUD for grocery-tracker: recipes, pantry, price_history, budget_plans/meals, quick_list, purchase_frequency, with versioned migrations and JSON backup/restore.

**DB file:** `os.path.join(DATA_DIR, "grocery.db")` — DATA_DIR from env, defaults to cwd.

**Tables:**
- `recipes` (id TEXT PK, name, url, ingredients JSON, saved_at)
- `pantry` (id AUTOINCREMENT, item UNIQUE)
- `price_history` (ingredient, product_name, price, date — UNIQUE on ingredient+date)
- `budget_plans` (id, name, weekly_budget, is_active)
- `budget_meals` (id TEXT PK, plan_id FK, day, meal_name, ingredients JSON, priced_items JSON, total)
- `quick_list` (id, product_name, price, image, aisle, category, quantity, checked)
- `purchase_frequency` (product_name UNIQUE, add_count — upserted on every add)
- `schema_version` (version PK) — for migrations

**Migration pattern:** `MIGRATIONS` dict maps version int → SQL string. `_run_migrations()` applies any unapplied versions on startup.

**One-time JSON migration:** `migrate_from_json()` imports recipes.json, pantry.json, price_history.json then renames them to `.migrated`.

**Backup/restore:** `db_export_all()` / `db_import_all(data)` — full snapshot as dict (version=1).',NULL,NULL,NULL,'not_chunked');
INSERT OR IGNORE INTO nodes (id,title,description,notes,link,event_date,created_at,updated_at,metadata,chunk,embedding,embedding_updated_at,embedding_text,chunk_status) VALUES (11,'grocery-tracker — Chrome Extension (grocery-extension/)','Chrome extension that scrapes the active tab''s text, sends it to the Railway-deployed Flask app to extract recipe ingredients via Claude, and opens the recipes page.','**Files:** manifest.json, popup.html, popup.js

**Flow:**
1. User clicks "Extract Recipe" in popup (optionally sets a recipe name)
2. Extension uses chrome.scripting.executeScript to grab `document.body.innerText` from active tab
3. POSTs first 8000 chars to `POST /extract-recipe` on Railway app (hardcoded BASE_URL)
4. On success shows ingredient count; on failure shows error

**BASE_URL:** hardcoded to `https://web-production-fcb56.up.railway.app`

**Permissions needed:** tabs, scripting, activeTab (from manifest)

**Note:** Recipe extraction uses Claude via `get_ingredients_from_text()` in routes/recipes.py → routes/search.py',NULL,NULL,'2026-03-16T11:13:38.645Z','2026-03-16T11:13:38.645Z','{}','grocery-tracker — Chrome Extension (grocery-extension/)

Chrome extension that scrapes the active tab''s text, sends it to the Railway-deployed Flask app to extract recipe ingredients via Claude, and opens the recipes page.

**Files:** manifest.json, popup.html, popup.js

**Flow:**
1. User clicks "Extract Recipe" in popup (optionally sets a recipe name)
2. Extension uses chrome.scripting.executeScript to grab `document.body.innerText` from active tab
3. POSTs first 8000 chars to `POST /extract-recipe` on Railway app (hardcoded BASE_URL)
4. On success shows ingredient count; on failure shows error

**BASE_URL:** hardcoded to `https://web-production-fcb56.up.railway.app`

**Permissions needed:** tabs, scripting, activeTab (from manifest)

**Note:** Recipe extraction uses Claude via `get_ingredients_from_text()` in routes/recipes.py → routes/search.py',NULL,NULL,NULL,'not_chunked');
INSERT OR IGNORE INTO nodes (id,title,description,notes,link,event_date,created_at,updated_at,metadata,chunk,embedding,embedding_updated_at,embedding_text,chunk_status) VALUES (12,'grocery-tracker — routes/budget.py (Weekly Meal Planner)','Budget planner routes — lets users assign priced meals to days of the week, tracks weekly spend against a budget, and can push all meal ingredients to the quick list.','**Routes:**
- `GET /api/budget` — returns active plan with meals organised by day
- `POST /api/budget/settings` — update weekly_budget amount
- `POST /api/budget/meal` — add meal by name: prices ingredients via Kroger API on the fly
- `POST /api/budget/meal-priced` — add meal with pre-priced items (skips Kroger lookup)
- `DELETE /api/budget/meal/<day>/<meal_id>` — remove a meal
- `GET /api/budget/shopping-list` — deduplicated ingredient list sorted by aisle number
- `POST /api/budget/shopping-list/push` — pushes all budget ingredients into quick_list table

**Budget model:** one active plan at a time (is_active=1). Auto-creates default plan (weekly_budget=150) if none exists.',NULL,NULL,'2026-03-16T11:13:48.577Z','2026-03-16T11:13:48.577Z','{}','grocery-tracker — routes/budget.py (Weekly Meal Planner)

Budget planner routes — lets users assign priced meals to days of the week, tracks weekly spend against a budget, and can push all meal ingredients to the quick list.

**Routes:**
- `GET /api/budget` — returns active plan with meals organised by day
- `POST /api/budget/settings` — update weekly_budget amount
- `POST /api/budget/meal` — add meal by name: prices ingredients via Kroger API on the fly
- `POST /api/budget/meal-priced` — add meal with pre-priced items (skips Kroger lookup)
- `DELETE /api/budget/meal/<day>/<meal_id>` — remove a meal
- `GET /api/budget/shopping-list` — deduplicated ingredient list sorted by aisle number
- `POST /api/budget/shopping-list/push` — pushes all budget ingredients into quick_list table

**Budget model:** one active plan at a time (is_active=1). Auto-creates default plan (weekly_budget=150) if none exists.',NULL,NULL,NULL,'not_chunked');
INSERT OR IGNORE INTO nodes (id,title,description,notes,link,event_date,created_at,updated_at,metadata,chunk,embedding,embedding_updated_at,embedding_text,chunk_status) VALUES (13,'grocery-tracker — routes/quicklist.py (Shopping List)','Quick shopping list routes — manages a persistent list of products with quantities, check-off state, and purchase frequency tracking for smart suggestions.','**Routes:**
- `GET /api/quick-list` — full list ordered by added_at
- `POST /api/quick-list` — add item (auto-increments quantity if already present)
- `POST /api/quick-list/bulk` — add multiple items at once
- `POST /api/quick-list/clear-checked` — remove all checked items
- `DELETE /api/quick-list/<id>` — remove item
- `POST /api/quick-list/<id>/quantity` — set quantity (deletes if ≤0)
- `POST /api/quick-list/<id>/toggle` — toggle checked state
- `POST /api/quick-list/clear` — wipe entire list
- `GET /api/frequent-items?limit=8` — top items by add_count from purchase_frequency table

**Side effect:** every `db_add_quick_list_item` call also upserts `purchase_frequency` (increments add_count).',NULL,NULL,'2026-03-16T11:13:53.596Z','2026-03-16T11:13:53.596Z','{}','grocery-tracker — routes/quicklist.py (Shopping List)

Quick shopping list routes — manages a persistent list of products with quantities, check-off state, and purchase frequency tracking for smart suggestions.

**Routes:**
- `GET /api/quick-list` — full list ordered by added_at
- `POST /api/quick-list` — add item (auto-increments quantity if already present)
- `POST /api/quick-list/bulk` — add multiple items at once
- `POST /api/quick-list/clear-checked` — remove all checked items
- `DELETE /api/quick-list/<id>` — remove item
- `POST /api/quick-list/<id>/quantity` — set quantity (deletes if ≤0)
- `POST /api/quick-list/<id>/toggle` — toggle checked state
- `POST /api/quick-list/clear` — wipe entire list
- `GET /api/frequent-items?limit=8` — top items by add_count from purchase_frequency table

**Side effect:** every `db_add_quick_list_item` call also upserts `purchase_frequency` (increments add_count).',NULL,NULL,NULL,'not_chunked');
INSERT OR IGNORE INTO nodes (id,title,description,notes,link,event_date,created_at,updated_at,metadata,chunk,embedding,embedding_updated_at,embedding_text,chunk_status) VALUES (14,'Stridemon — Walking Creature Collection Game','Active personal project — a React-based mobile-style game where real-world walking earns coins to hatch and collect creatures. Full feature set including health profile, step goals, fusions, and daily quests.','## Core Loop
Walk steps → earn coins (100 steps = 1 coin) → buy eggs → hatch creatures → train/evolve/fuse

## Features (Current)
- Manual step logging with daily goal progress bar
- Health profile: weight, height, age, fitness goal (Imperial + Metric planned)
- Calorie burn + miles walked calculated from profile
- 4-week personalized ramp-up plan
- 15 creatures across 4 types: Fantasy, Cute, Monster, Fusion
- 3 egg tiers: Common, Rare, Epic (real-time incubation timers)
- Creature abilities — each creature has a unique passive that modifies gameplay
- Evolution chains (50 XP threshold), 3 fusion recipes
- Happiness system (0–100), mood states, petting, training
- Nickname + journal per creature
- 7 daily quests, 8 lifetime milestones, 14 achievements
- Particle effects (hatch, evolve, fusion, goal, milestone)
- Goal celebration screen
- Onboarding flow (4 slides)
- Sort/filter in collection tab
- Retroactive step logging (past dates)
- Settings: sound, notifications, theme, unit system, reset quests

## Tech Stack
- React JSX (single file component)
- Deployed/run as artifact in Claude.ai
- No backend — all state in React useState

## Planned
- Custom creature art (player-drawn, replacing emoji)
- Whimsical light/dark theme inspired by watercolor game UI (cutekart.com reference)
- Metric unit system support in health profile',NULL,NULL,'2026-03-16T12:23:25.600Z','2026-03-16T12:23:25.600Z','{}','Stridemon — Walking Creature Collection Game

Active personal project — a React-based mobile-style game where real-world walking earns coins to hatch and collect creatures. Full feature set including health profile, step goals, fusions, and daily quests.

## Core Loop
Walk steps → earn coins (100 steps = 1 coin) → buy eggs → hatch creatures → train/evolve/fuse

## Features (Current)
- Manual step logging with daily goal progress bar
- Health profile: weight, height, age, fitness goal (Imperial + Metric planned)
- Calorie burn + miles walked calculated from profile
- 4-week personalized ramp-up plan
- 15 creatures across 4 types: Fantasy, Cute, Monster, Fusion
- 3 egg tiers: Common, Rare, Epic (real-time incubation timers)
- Creature abilities — each creature has a unique passive that modifies gameplay
- Evolution chains (50 XP threshold), 3 fusion recipes
- Happiness system (0–100), mood states, petting, training
- Nickname + journal per creature
- 7 daily quests, 8 lifetime milestones, 14 achievements
- Particle effects (hatch, evolve, fusion, goal, milestone)
- Goal celebration screen
- Onboarding flow (4 slides)
- Sort/filter in collection tab
- Retroactive step logging (past dates)
- Settings: sound, notifications, theme, unit system, reset quests

## Tech Stack
- React JSX (single file component)
- Deployed/run as artifact in Claude.ai
- No backend — all state in React useState

## Planned
- Custom creature art (player-drawn, replacing emoji)
- Whimsical light/dark theme inspired by watercolor game UI (cutekart.com reference)
- Metric unit system support in health profile',NULL,NULL,NULL,'not_chunked');
INSERT OR IGNORE INTO nodes (id,title,description,notes,link,event_date,created_at,updated_at,metadata,chunk,embedding,embedding_updated_at,embedding_text,chunk_status) VALUES (15,'Stridemon — Creature Art Style Guide','Art style guide for Stridemon creature sprites — vector-influenced digital illustration with bold outlines, flat + airbrushed shading, neon accents, and yellow-green eyes as a universal unifying element across all 15 creatures.','## Style DNA (from reference image)
- Bold, saturated body colors — one dominant color per creature
- Thick black outlines with varying stroke weight (thicker outside, thinner inside)
- Flat color base + one airbrush shadow pass (multiply blend mode)
- Neon accent colors that contrast the body (cyan, hot pink, lime, orange)
- Yellow-green eyes (#c8e000) with black slit pupil + white dot highlight — same formula on EVERY creature for brand cohesion
- Off-white teeth (#f5f0d0), near-black outline (#1a1a1a)
- Slimy texture via dark spots, drip shapes, and highlight blobs on a top layer

## Creature Formula (Step by Step)
1. Silhouette first — readable as a solid shape
2. Add chaos features: extra eyes, horns, wings, tentacles
3. Flat color fill (max 5–6 colors per creature)
4. One shadow pass — underside and recesses only
5. Yellow-green eyes — copy-paste the same one every time
6. Slime/texture details — circles and teardrops
7. Outline pass — vary weight outer vs inner

## Per-Type Guidelines
- Fantasy: sleek, jewel-toned, scales, elegant horns
- Cute: round blobs, single big eye, stubby limbs, pastel accent
- Monster: chaotic, asymmetric, multiple eyes, open mouth, drips
- Fusion: mix of both parent color palettes, one visible feature from each parent
- Evolved forms: same proportions + one major new feature (wings, crown, extra limbs)

## Proportions (Chibi/Toy)
- Head = 40–45% of total height
- Stubby limbs, round feet pointing slightly outward
- Simple rounded rectangle body

## Recommended Tools
- Procreate (iPad) — best overall fit, $13
- Clip Studio Paint — great inking, ~$50
- Affinity Designer — vector, ~$20
- Krita — free alternative

## Shortcuts
- Draw the eye once, copy-paste and resize for every creature
- Reuse/mirror claw and limb shapes
- Make one mouth template, vary the outer shape only
- Use a brush stamp for slime spots
- Work all 15 creatures on one canvas for constant color comparison

## File Delivery Spec
- PNG, transparent background
- Named by creature ID: ember.png, lumis.png, fluffi.png etc.
- 256×256px recommended (or 64×64 for pixel art scale)',NULL,NULL,'2026-03-16T12:23:47.272Z','2026-03-16T12:23:47.272Z','{}','Stridemon — Creature Art Style Guide

Art style guide for Stridemon creature sprites — vector-influenced digital illustration with bold outlines, flat + airbrushed shading, neon accents, and yellow-green eyes as a universal unifying element across all 15 creatures.

## Style DNA (from reference image)
- Bold, saturated body colors — one dominant color per creature
- Thick black outlines with varying stroke weight (thicker outside, thinner inside)
- Flat color base + one airbrush shadow pass (multiply blend mode)
- Neon accent colors that contrast the body (cyan, hot pink, lime, orange)
- Yellow-green eyes (#c8e000) with black slit pupil + white dot highlight — same formula on EVERY creature for brand cohesion
- Off-white teeth (#f5f0d0), near-black outline (#1a1a1a)
- Slimy texture via dark spots, drip shapes, and highlight blobs on a top layer

## Creature Formula (Step by Step)
1. Silhouette first — readable as a solid shape
2. Add chaos features: extra eyes, horns, wings, tentacles
3. Flat color fill (max 5–6 colors per creature)
4. One shadow pass — underside and recesses only
5. Yellow-green eyes — copy-paste the same one every time
6. Slime/texture details — circles and teardrops
7. Outline pass — vary weight outer vs inner

## Per-Type Guidelines
- Fantasy: sleek, jewel-toned, scales, elegant horns
- Cute: round blobs, single big eye, stubby limbs, pastel accent
- Monster: chaotic, asymmetric, multiple eyes, open mouth, drips
- Fusion: mix of both parent color palettes, one visible feature from each parent
- Evolved forms: same proportions + one major new feature (wings, crown, extra limbs)

## Proportions (Chibi/Toy)
- Head = 40–45% of total height
- Stubby limbs, round feet pointing slightly outward
- Simple rounded rectangle body

## Recommended Tools
- Procreate (iPad) — best overall fit, $13
- Clip Studio Paint — great inking, ~$50
- Affinity Designer — vector, ~$20
- Krita — free alternative

## Shortcuts
- Draw the eye once, copy-paste and resize for every creature
- Reuse/mirror claw and limb shapes
- Make one mouth template, vary the outer shape only
- Use a brush stamp for slime spots
- Work all 15 creatures on one canvas for constant color comparison

## File Delivery Spec
- PNG, transparent background
- Named by creature ID: ember.png, lumis.png, fluffi.png etc.
- 256×256px recommended (or 64×64 for pixel art scale)',NULL,NULL,NULL,'not_chunked');
INSERT OR IGNORE INTO nodes (id,title,description,notes,link,event_date,created_at,updated_at,metadata,chunk,embedding,embedding_updated_at,embedding_text,chunk_status) VALUES (16,'Prometheus — Educational TikTok Feed App','App concept — a vertical swipe feed powered by Claude AI that pulls from real content sources and rewrites everything into personalized 2-5 sentence learning cards, with dynamic interest tracking that evolves with the user over time.','A vertical swipe feed (TikTok-style) that pulls from multiple real content sources and uses Claude AI to generate personalized digestible learning cards. Users pick topic categories and sources on signup. Content pipeline pulls from Hacker News, Reddit, Arxiv, PubMed, Genius, YouTube transcripts, RSS feeds, and more — Claude filters and rewrites everything into 2-5 sentence cards personalized to each user''s interest profile and depth setting.

Card types: Quick Fact, Thread, Connection Drop, Source Highlight, Recall Challenge, New Leaf, Trending

"Go Deeper" feature: 3 layers — card → explainer → rabbit hole topic web
Rabbit hole: Claude generates 5 subtopic chips per topic, each tappable, infinitely branchable
Session summary: Claude synthesizes full research session at the end
Shareable with friends/family via PWA link — no App Store needed
No social features — just shared access with per-user interest profiles
"Add to Brain" button saves any card directly as a new RA-H node

## Evolving Interest System (added 2026-03-16)

Profile schema (v2):
- core: string[] — original onboarding picks, always in feed
- following: string[] — added via tap mid-feed or session suggestion
- muted: string[] — actively down-signaled, excluded from New Leaf sourcing
- depth: ''casual'' | ''moderate'' | ''deep''

### Features

1. Tap-to-Follow on any card — every card shows its topic tag with a ''+'' button. One tap adds to ''following''. No settings screen needed.

2. New Leaf cards are actionable — surfaces content outside your profile with explicit opt-in: ''Add to My Interests'' / ''Keep Exploring'' / ''Not for me''. ''Not for me'' writes to muted.

3. Session summary one-tap add — suggestedTopics[] rendered as chips with ''+'' button. Catches interest drift that happened organically across the session.

4. Interest Pulse (new card type, every 10 sessions) — Haiku analyzes engagement patterns and surfaces a lightweight profile tune-up card: promotes topics you went deeper on, flags topics you''ve ignored, suggests related topics. One-tap yes/no per suggestion.

5. Explore Mode (Phase 6) — second feed tab, unfiltered by profile. Any card can be saved to following via ''+'' tap. Discovery surface vs. personalized surface.

### Card types (full list)
Quick Fact, Thread, Connection Drop, Source Highlight, Recall Challenge, New Leaf, Trending, Pulse Check (new)',NULL,NULL,'2026-03-16T17:11:05.567Z','2026-03-16T17:24:45.959Z','{}','EduScroll — Educational TikTok Feed App

App concept — a vertical swipe feed powered by Claude AI that pulls from real content sources and rewrites everything into personalized 2-5 sentence learning cards. Core interface for a friend/family learning tool with no social features.

A vertical swipe feed (TikTok-style) that pulls from multiple real content sources and uses Claude AI to generate personalized digestible learning cards. Users pick topic categories and sources on signup. Content pipeline pulls from Hacker News, Reddit, Arxiv, PubMed, Genius, YouTube transcripts, RSS feeds, and more — Claude filters and rewrites everything into 2-5 sentence cards personalized to each user''s interest profile and depth setting.

Card types: Quick Fact, Thread, Connection Drop, Source Highlight, Recall Challenge, New Leaf, Trending

"Go Deeper" feature: 3 layers — card → explainer → rabbit hole topic web
Rabbit hole: Claude generates 5 subtopic chips per topic, each tappable, infinitely branchable
Session summary: Claude synthesizes full research session at the end
Shareable with friends/family via PWA link — no App Store needed
No social features — just shared access with per-user interest profiles
"Add to Brain" button saves any card directly as a new RA-H node',NULL,NULL,NULL,'not_chunked');
INSERT OR IGNORE INTO nodes (id,title,description,notes,link,event_date,created_at,updated_at,metadata,chunk,embedding,embedding_updated_at,embedding_text,chunk_status) VALUES (17,'Prometheus — Tech Stack & Optimization Plan','Tech stack decisions and build progress for Prometheus — tracks active Next.js build at prometheus-next and legacy Vite build at prometheus, with phase completion status.','Stack: React PWA → Vercel (free) → Vercel Serverless Functions → Upstash Redis cache (free tier) → Claude API

Caching strategy: source cache (2hr refresh), card cache (24hr), rabbit hole cache (per topic)
Batch card generation: 10 cards per Claude call instead of 1
Model split: Haiku for filtering/subtopics, Sonnet for full card writing
Feature flags + env vars for everything — easy to upgrade any layer independently
Modular source adapters: each content source is one file with a standard fetchLatest() interface
Forward-compatible user preference schema with version field

Build order: shell → serverless functions → Redis cache → cron job → user prefs → Go Deeper → rabbit hole



## prometheus-next (Next.js 14) — Phase 1 Complete (2026-03-16)

Active build. Supersedes the Vite app.

### Stack
- Next.js 14 + TypeScript + Tailwind (Vercel free)
- YouTube Data API v3 (10k units/day free)
- Claude Haiku for search summaries
- Supabase Auth + PostgreSQL (Phase 3)
- Upstash Redis (Phase 2)

### Phase 1 Done
- Homepage search bar → /search?q=
- /api/youtube — top 5 YouTube results
- /api/search — YouTube + Claude Haiku summary
- /search results page — AI summary pinned top, VideoCard grid, skeleton loading
- Single col mobile / 3-col desktop, tap-to-play inline video

### Phase 2 Next
- Reddit (no key), Articles (rss2json), Images (Unsplash)
- All fetches parallel in /api/search, one Claude call with all results
- RedditCard, ArticleCard, ImageCard components',NULL,NULL,'2026-03-16T17:11:11.570Z','2026-03-16T21:13:09.379Z','{}','EduScroll — Tech Stack & Optimization Plan

Architecture plan — zero-cost stack for EduScroll using React PWA, Vercel, Upstash Redis, and Claude API with aggressive caching to hit ~$0.50-1.00/month for a small friend/family group.

Stack: React PWA → Vercel (free) → Vercel Serverless Functions → Upstash Redis cache (free tier) → Claude API

Caching strategy: source cache (2hr refresh), card cache (24hr), rabbit hole cache (per topic)
Batch card generation: 10 cards per Claude call instead of 1
Model split: Haiku for filtering/subtopics, Sonnet for full card writing
Feature flags + env vars for everything — easy to upgrade any layer independently
Modular source adapters: each content source is one file with a standard fetchLatest() interface
Forward-compatible user preference schema with version field

Build order: shell → serverless functions → Redis cache → cron job → user prefs → Go Deeper → rabbit hole',NULL,NULL,NULL,'not_chunked');
INSERT OR IGNORE INTO nodes (id,title,description,notes,link,event_date,created_at,updated_at,metadata,chunk,embedding,embedding_updated_at,embedding_text,chunk_status) VALUES (18,'Prometheus — Content Source Map by Domain','Reference map — all free content APIs and RSS feeds organized by interest domain that feed the Prometheus card generation pipeline, now covering AI/tech, game dev, wellness, rap, YouTube, Rocket League, philosophy, and comics.','AI/Tech: Hacker News API, Arxiv API, Semantic Scholar, Anthropic/OpenAI/DeepMind blogs, MIT Tech Review RSS
Game Dev: Godot blog RSS, GDQuest YouTube transcripts, r/godot, itch.io devlogs
Wellness: PubMed API, PsyArXiv, Greater Good Science Center, Huberman Lab transcripts, Examine.com
Rap/Writing: Genius API, Poetry Foundation API, The Paris Review RSS, r/WeAreTheMusicMakers
YouTube/Creator: VidIQ blog, Creator Insider transcripts, Creator Science newsletter
Rocket League: r/RocketLeague, Liquipedia, SunlessKhan/Musty/Lethamyr transcripts

Free no-key APIs: Hacker News, Reddit, PubMed, Poetry Foundation, Arxiv, Wikipedia
Free with key: Genius, Merriam-Webster, YouTube Data API



Philosophy: Stanford Encyclopedia of Philosophy (free API), Daily Stoic RSS, Philosophy Bro RSS, Partially Examined Life podcast transcripts, r/philosophy, Internet Encyclopedia of Philosophy
Comics/Superhero: r/Marvel, r/DCcomics, Marvel.com news RSS, DC Blog RSS, CBR RSS, Screen Rant comics RSS, Comicsbeat RSS

Free no-key additions: SEP API, Reddit (r/philosophy, r/Marvel, r/DCcomics), RSS feeds above',NULL,NULL,'2026-03-16T17:11:18.760Z','2026-03-16T23:51:19.156Z','{}','EduScroll — Content Source Map by Domain

Reference map — all free content APIs and RSS feeds organized by interest domain that feed the EduScroll card generation pipeline, covering AI/tech, game dev, wellness, rap, YouTube, and Rocket League.

AI/Tech: Hacker News API, Arxiv API, Semantic Scholar, Anthropic/OpenAI/DeepMind blogs, MIT Tech Review RSS
Game Dev: Godot blog RSS, GDQuest YouTube transcripts, r/godot, itch.io devlogs
Wellness: PubMed API, PsyArXiv, Greater Good Science Center, Huberman Lab transcripts, Examine.com
Rap/Writing: Genius API, Poetry Foundation API, The Paris Review RSS, r/WeAreTheMusicMakers
YouTube/Creator: VidIQ blog, Creator Insider transcripts, Creator Science newsletter
Rocket League: r/RocketLeague, Liquipedia, SunlessKhan/Musty/Lethamyr transcripts

Free no-key APIs: Hacker News, Reddit, PubMed, Poetry Foundation, Arxiv, Wikipedia
Free with key: Genius, Merriam-Webster, YouTube Data API',NULL,NULL,NULL,'not_chunked');
INSERT OR IGNORE INTO nodes (id,title,description,notes,link,event_date,created_at,updated_at,metadata,chunk,embedding,embedding_updated_at,embedding_text,chunk_status) VALUES (19,'RA-H Graph — App Ideas Brainstorm','Ideas brainstorm — collection of apps that use the RA-H knowledge graph as a database and Claude as the engine, each exposing a different interface into the same second brain. Graph gets smarter, all apps improve automatically.','Knowledge Feed (EduScroll variant): scroll feed from personal graph nodes
Huge Papa Dashboard: mission control pulling live status from all graph nodes
Knowledge Gauntlet: quiz/trivia game from node content with XP and badges
Trend Oracle: AI prediction engine from AI & Tech Trends node + web search
Second Brain Garden: interactive force-directed graph visualization
Huge Papa Protocol: health/habit tracker powered by wellness node + Stridemon integration
Content Brain: YouTube idea engine cross-pollinating all graph domains
Stridemon Lore Bible: dedicated worldbuilding tool for creature design and game lore

Meta pattern: graph = database, Claude = engine, app = interface. Graph gets smarter, all apps improve automatically.',NULL,NULL,'2026-03-16T17:11:26.198Z','2026-03-16T17:22:45.584Z','{}','RA-H Graph — App Ideas Brainstorm

Ideas brainstorm — collection of apps that use the RA-H knowledge graph as a database and Claude as the engine, each exposing a different interface into the same second brain. Graph gets smarter, all apps improve automatically.

Knowledge Feed (EduScroll variant): scroll feed from personal graph nodes
Huge Papa Dashboard: mission control pulling live status from all graph nodes
Knowledge Gauntlet: quiz/trivia game from node content with XP and badges
Trend Oracle: AI prediction engine from AI & Tech Trends node + web search
Second Brain Garden: interactive force-directed graph visualization
Huge Papa Protocol: health/habit tracker powered by wellness node + Stridemon integration
Content Brain: YouTube idea engine cross-pollinating all graph domains
Stridemon Lore Bible: dedicated worldbuilding tool for creature design and game lore

Meta pattern: graph = database, Claude = engine, app = interface. Graph gets smarter, all apps improve automatically.',NULL,NULL,NULL,'not_chunked');
INSERT OR IGNORE INTO nodes (id,title,description,notes,link,event_date,created_at,updated_at,metadata,chunk,embedding,embedding_updated_at,embedding_text,chunk_status) VALUES (20,'Prometheus — Project Rules & Constraints','Standing rules set by Braddon for all Prometheus development decisions — governs monetization, architecture costs, platform targets, UI interaction standards, and requires Claude to flag deviations before acting.','Rules as of March 16, 2026:

RULE 1 — No Paywalls (initially)
The app must be fully free to access for all users with no paywalled features. Braddon may want to introduce paywalls later, but no paywall features should be designed or built without explicit approval first. Claude must notify Braddon before suggesting any feature that would require users to pay.

RULE 2 — Free or Extremely Cheap Architecture Only
Every tool, service, API, or infrastructure choice must either be completely free or extremely cheap. Before recommending or implementing anything that requires payment (even small amounts), Claude must check with Braddon first and present the cost clearly before proceeding. Free tiers are always preferred. If a paid option is the only viable solution, it must be flagged with the exact cost before any action is taken.

DEVIATION PROTOCOL
If Claude believes it must deviate from either rule for a legitimate reason, it must:
1. Stop before taking action
2. Clearly state which rule it needs to deviate from
3. Explain exactly why
4. Ask for explicit approval before proceeding


RULE 3 — Desktop & Mobile Support
Prometheus must work on both desktop and mobile from the start. This is not a post-launch consideration. Every UI component, layout, and feature must be designed and built responsively. Mobile experience should feel native, not like a shrunken desktop site. The feed mode in particular should feel natural on mobile (thumb-scrollable, tap-friendly). Desktop should take advantage of wider layouts (multi-column grids, side panels).

RULE 3 SUB-DIRECTION — No Hover-Only Interactions
Every interactive UI element must have both a hover state (desktop) AND a tap/touch equivalent (mobile). Claude Code must never implement core functionality that relies solely on CSS hover states, as hover is invisible on mobile devices. Examples of what to avoid: dropdown menus that only open on hover, buttons that only reveal on hover, tooltips that are the only way to access information. Every hover interaction must have a corresponding tap, long-press, or always-visible mobile alternative. When prompting Claude Code for any interactive component, always specify both the hover behavior AND the mobile tap behavior explicitly.

RULE 4 — PWA Custom Icon
All PWA builds must include a custom Prometheus app icon so it displays correctly when added to home screen on iOS and Android. Icon must be provided as a square PNG at multiple sizes: 192x192 (Android), 512x512 (Android splash), and 180x180 (Apple touch icon for iOS). These must be referenced correctly in manifest.json and in the Next.js Head/metadata config. Claude must never ship a PWA setup without confirming the icon files are in place and properly linked.',NULL,NULL,'2026-03-16T20:42:23.060Z','2026-03-16T20:49:02.725Z','{}','Prometheus — Project Rules & Constraints

Standing rules set by Braddon for all Prometheus development decisions — governs monetization, architecture costs, and requires Claude to flag deviations before acting.

Rules as of March 16, 2026:

RULE 1 — No Paywalls (initially)
The app must be fully free to access for all users with no paywalled features. Braddon may want to introduce paywalls later, but no paywall features should be designed or built without explicit approval first. Claude must notify Braddon before suggesting any feature that would require users to pay.

RULE 2 — Free or Extremely Cheap Architecture Only
Every tool, service, API, or infrastructure choice must either be completely free or extremely cheap. Before recommending or implementing anything that requires payment (even small amounts), Claude must check with Braddon first and present the cost clearly before proceeding. Free tiers are always preferred. If a paid option is the only viable solution, it must be flagged with the exact cost before any action is taken.

DEVIATION PROTOCOL
If Claude believes it must deviate from either rule for a legitimate reason, it must:
1. Stop before taking action
2. Clearly state which rule it needs to deviate from
3. Explain exactly why
4. Ask for explicit approval before proceeding',NULL,NULL,NULL,'not_chunked');
INSERT OR IGNORE INTO nodes (id,title,description,notes,link,event_date,created_at,updated_at,metadata,chunk,embedding,embedding_updated_at,embedding_text,chunk_status) VALUES (21,'Prometheus — Full Planning Session (March 16, 2026)','Complete conversation log and decisions from the Prometheus planning session — covers vision, full feature set, public-ready expansion, rules, responsive design, PWA icons, and Phase 1 build instructions for Claude Code.','## What Prometheus Is
A personal AI-powered search engine with a feed layer. Part Google, part TikTok, part Reddit — filtered through the user''s interests and memory. Three modes: Search Mode (query-driven results), Feed Mode (auto-generated personalized scroll), and Memory Mode (saved items and history influence future results).

---

## Core Features Decided

### Search Bar
- Query hits Next.js API route
- Claude receives query + user interest profile + search history
- Parallel API calls: YouTube, Reddit, NewsAPI/RSS, Unsplash
- Claude returns 3-5 sentence personalized summary at top
- Results grouped: Videos → Threads → Articles → Images
- Every search logged for personalization

### Results Page
- YouTube embed cards (inline playable via YouTube Data API v3)
- Reddit thread cards (top posts + expandable comments)
- Article/link cards (headline, source, Claude 1-sentence summary)
- Image cards (Unsplash grid)
- AI Summary block pinned at top (personalized to user history)
- Masonry grid desktop / single column mobile

### Feed Mode
- Guest feed: Claude-curated trending content, not personalized
- Registered feed: Personalized to interest profile + behavior history
- RA-H feed: Same as registered + knowledge graph nodes surfaced as cards
- Card types: Video, Discussion, Article, Image, AI Insight, Memory Card
- AI Insight cards are Claude-synthesized thoughts (not pulled from APIs)
- Memory cards: "You explored this 2 weeks ago — here''s what''s new"

### Memory System (Registered Users)
- Session memory: in-state
- Short-term: Upstash Redis (last 30 days)
- Long-term: Supabase PostgreSQL (saved items, interest profile)
- Claude receives compact "user context block" on every API call
- Inferred topic tags auto-generated from behavior (no manual tagging)

### Collections (Save & Organize)
- Any card saveable to named collections
- Private by default, toggleable to public
- Public collections shareable via link (growth/discovery mechanism)
- Saved items feed back into personalization layer

### RA-H Integration Layer
- Connect via MCP — queries graph as additional data source
- Personal nodes surface above external results labeled "From Your Knowledge Base"
- Additive only — never required, never degrades non-RA-H experience
- Non-RA-H users get Manual Graph: simplified node builder native to Prometheus

### Settings & Transparency
- Interest Manager, Search History, Saved Collections
- Feed Tuning (boost/suppress topics)
- RA-H Connection status
- Data Export (JSON)

---

## User Tiers
- Guest: Full search + feed, no memory, resets on session end
- Registered: Memory, collections, personalized feed, onboarding flow
- RA-H User: Everything above + knowledge graph layer

## Onboarding Flow (Registered)
1. Pick interest domains (multi-select tiles)
2. Set depth per domain (Casual → Enthusiast → Deep Dive slider)
3. First search prompt to seed the experience
Takes under 60 seconds, generates meaningful first feed immediately.

---

## Full Tech Stack (All Free)
- Frontend: Next.js 14 + TypeScript + Tailwind (Vercel free tier)
- Auth: Supabase Auth — magic link, no passwords (50k MAU free)
- Database: Supabase PostgreSQL (500MB free)
- Caching: Upstash Redis (10k req/day free)
- AI: Claude Sonnet API (~$0.50-2/mo with aggressive caching)
- Video: YouTube Data API v3 (10k units/day free)
- Discussions: Reddit API (free, no key needed for basic use)
- Articles: NewsAPI / RSS via rss2json.com (free tier)
- Images: Unsplash API (50 req/hour free)
- RA-H Layer: MCP connection (existing setup)

---

## Project Rules (Node #20)
RULE 1 — No Paywalls initially. Flag before suggesting any paid user-facing feature.
RULE 2 — Free or extremely cheap architecture only. Check with Braddon before any paid service.
RULE 3 — Desktop AND mobile support from day one. Mobile-first design always.
RULE 3 SUB-DIRECTION — No hover-only interactions. Every hover state must have an onClick/tap equivalent. Never implement core functionality behind CSS hover alone.
RULE 4 — PWA custom icon required. Must include 192x192 (Android), 512x512 (Android splash), 180x180 apple-touch-icon (iOS). Reference correctly in manifest.json and layout.tsx.
DEVIATION PROTOCOL — Stop, name the rule, explain why, ask for approval before proceeding.

---

## Responsive Design Decisions
- Tailwind mobile-first throughout (no separate mobile codebase)
- Search bar: full width mobile, max-width centered desktop
- Results: single column mobile, 2-3 column masonry desktop
- Feed: full-screen vertical swipe mobile, centered column + sidebar desktop
- Navigation: bottom tab bar mobile (Search/Feed/Saved/Profile), left sidebar desktop
- Video cards: full width tap-to-play mobile, hover overlay desktop
- PWA via next-pwa package — enables Add to Home Screen, fullscreen launch

---

## PWA Icon Setup
1. Generate icons at favicon.io or realfavicongenerator.net
2. Place in /public/icons/: icon-192x192.png, icon-512x512.png, apple-touch-icon.png
3. Reference in manifest.json under "icons" array
4. Add to app/layout.tsx: appleWebApp config + <link rel="apple-touch-icon"> in head
5. The apple-touch-icon link tag is what iOS needs — missing this causes generic screenshot icon
6. Tell Claude Code: "Wire icon-192x192.png, icon-512x512.png, apple-touch-icon.png from /public/icons/ into manifest.json and app/layout.tsx"

---

## Phase 1 Build Instructions (Start Here in Claude Code)

### Folder Structure
prometheus/
├── app/
│   ├── page.tsx                   ← Search bar homepage
│   ├── search/page.tsx            ← Results page
│   └── api/
│       ├── search/route.ts        ← Main search API route
│       └── youtube/route.ts       ← YouTube fetch route
├── components/
│   ├── SearchBar.tsx
│   ├── ResultsGrid.tsx
│   ├── VideoCard.tsx
│   └── AISummary.tsx
└── lib/
    ├── claude.ts                  ← Claude API helper
    └── youtube.ts                 ← YouTube API helper

### .env.local Required Keys
YOUTUBE_API_KEY=your_key_here
ANTHROPIC_API_KEY=your_key_here
(Get YouTube key at console.cloud.google.com → Enable YouTube Data API v3 → Credentials → Create API Key)

### Claude Code Prompt Sequence (Phase 1)
Prompt 1: "Create a Next.js 14 app with TypeScript and Tailwind called Prometheus. The homepage has a centered search bar, mobile-first layout. On submit it navigates to /search?q=[query]. No hover-only interactions — all interactive elements must have onClick/tap handlers."

Prompt 2: "Create a Next.js API route at /api/youtube that takes a query param, calls the YouTube Data API v3 search endpoint, and returns the top 5 video results with videoId, title, channelName, and thumbnailUrl."

Prompt 3: "Create a Next.js API route at /api/search that takes a query, calls the YouTube route in parallel with a Claude API call. Claude receives the query and YouTube results and returns a 3-5 sentence summary. Return both to the client."

Prompt 4: "Create a SearchResults page that calls /api/search, shows the Claude summary at the top, then renders VideoCard components below. Each VideoCard embeds the YouTube iframe player. Mobile-first layout, single column mobile, grid desktop. Every interactive element needs both hover state and onClick/tap handler."

### Phase 2 (After Phase 1 Working)
- Add Reddit: hit https://www.reddit.com/search.json?q=[query] (no key needed)
- Add Articles: rss2json.com free RSS-to-JSON service
- Add Images: Unsplash API (free key at unsplash.com/developers)
- Build RedditCard, ArticleCard, ImageCard components one at a time

### Phase 3 (After Results Page Solid)
- Supabase Auth (magic link login)
- search_history table: user_id, query, timestamp
- Inject last 10 searches into Claude prompt as context

### Phase 4 (After Memory Works)
- /feed page: fetch top 5 interest tags, run parallel searches, render card feed

### Phase 5
- Save & Collections (Supabase)

### Phase 6
- Manual Graph (simplified node builder for non-RA-H users)

### Phase 7
- RA-H MCP integration

### Phase 8
- Settings + transparency panel

---

## Key Claude Code Habits
- One file/component per prompt — never give too large a scope
- Always specify mobile AND desktop layout in every component prompt
- Always end prompts with: "Every interactive element must have both a hover state for desktop and an onClick/tap handler for mobile. No functionality should be hover-only."
- Commit after each working piece before moving on
- Watch for hover-only interactions Claude Code generates by default',NULL,NULL,'2026-03-16T21:03:25.543Z','2026-03-16T21:03:25.543Z','{}','Prometheus — Full Planning Session (March 16, 2026)

Complete conversation log and decisions from the Prometheus planning session — covers vision, full feature set, public-ready expansion, rules, responsive design, PWA icons, and Phase 1 build instructions for Claude Code.

## What Prometheus Is
A personal AI-powered search engine with a feed layer. Part Google, part TikTok, part Reddit — filtered through the user''s interests and memory. Three modes: Search Mode (query-driven results), Feed Mode (auto-generated personalized scroll), and Memory Mode (saved items and history influence future results).

---

## Core Features Decided

### Search Bar
- Query hits Next.js API route
- Claude receives query + user interest profile + search history
- Parallel API calls: YouTube, Reddit, NewsAPI/RSS, Unsplash
- Claude returns 3-5 sentence personalized summary at top
- Results grouped: Videos → Threads → Articles → Images
- Every search logged for personalization

### Results Page
- YouTube embed cards (inline playable via YouTube Data API v3)
- Reddit thread cards (top posts + expandable comments)
- Article/link cards (headline, source, Claude 1-sentence summary)
- Image cards (Unsplash grid)
- AI Summary block pinned at top (personalized to user history)
- Masonry grid desktop / single column mobile

### Feed Mode
- Guest feed: Claude-curated trending content, not personalized
- Registered feed: Personalized to interest profile + behavior history
- RA-H feed: Same as registered + knowledge graph nodes surfaced as cards
- Card types: Video, Discussion, Article, Image, AI Insight, Memory Card
- AI Insight cards are Claude-synthesized thoughts (not pulled from APIs)
- Memory cards: "You explored this 2 weeks ago — here''s what''s new"

### Memory System (Registered Users)
- Session memory: in-state
- Short-term: Upstash Redis (last 30 days)
- Long-term: Supabase PostgreSQL (saved items, interest profile)
- Claude receives compact "user context block" on every API call
- Inferred topic tags auto-generated from behavior (no manual tagging)

### Collections (Save & Organize)
- Any card saveable to named collections
- Private by default, toggleable to public
- Public collections shareable via link (growth/discovery mechanism)
- Saved items feed back into personalization layer

### RA-H Integration Layer
- Connect via MCP — queries graph as additional data source
- Personal nodes surface above external results labeled "From Your Knowledge Base"
- Additive only — never required, never degrades non-RA-H experience
- Non-RA-H users get Manual Graph: simplified node builder native to Prometheus

### Settings & Transparency
- Interest Manager, Search History, Saved Collections
- Feed Tuning (boost/suppress topics)
- RA-H Connection status
- Data Export (JSON)

---

## User Tiers
- Guest: Full search + feed, no memory, resets on session end
- Registered: Memory, collections, personalized feed, onboarding flow
- RA-H User: Everything above + knowledge graph layer

## Onboarding Flow (Registered)
1. Pick interest domains (multi-select tiles)
2. Set depth per domain (Casual → Enthusiast → Deep Dive slider)
3. First search prompt to seed the experience
Takes under 60 seconds, generates meaningful first feed immediately.

---

## Full Tech Stack (All Free)
- Frontend: Next.js 14 + TypeScript + Tailwind (Vercel free tier)
- Auth: Supabase Auth — magic link, no passwords (50k MAU free)
- Database: Supabase PostgreSQL (500MB free)
- Caching: Upstash Redis (10k req/day free)
- AI: Claude Sonnet API (~$0.50-2/mo with aggressive caching)
- Video: YouTube Data API v3 (10k units/day free)
- Discussions: Reddit API (free, no key needed for basic use)
- Articles: NewsAPI / RSS via rss2json.com (free tier)
- Images: Unsplash API (50 req/hour free)
- RA-H Layer: MCP connection (existing setup)

---

## Project Rules (Node #20)
RULE 1 — No Paywalls initially. Flag before suggesting any paid user-facing feature.
RULE 2 — Free or extremely cheap architecture only. Check with Braddon before any paid service.
RULE 3 — Desktop AND mobile support from day one. Mobile-first design always.
RULE 3 SUB-DIRECTION — No hover-only interactions. Every hover state must have an onClick/tap equivalent. Never implement core functionality behind CSS hover alone.
RULE 4 — PWA custom icon required. Must include 192x192 (Android), 512x512 (Android splash), 180x180 apple-touch-icon (iOS). Reference correctly in manifest.json and layout.tsx.
DEVIATION PROTOCOL — Stop, name the rule, explain why, ask for approval before proceeding.

---

## Responsive Design Decisions
- Tailwind mobile-first throughout (no separate mobile codebase)
- Search bar: full width mobile, max-width centered desktop
- Results: single column mobile, 2-3 column masonry desktop
- Feed: full-screen vertical swipe mobile, centered column + sidebar desktop
- Navigation: bottom tab bar mobile (Search/Feed/Saved/Profile), left sidebar desktop
- Video cards: full width tap-to-play mobile, hover overlay desktop
- PWA via next-pwa package — enables Add to Home Screen, fullscreen launch

---

## PWA Icon Setup
1. Generate icons at favicon.io or realfavicongenerator.net
2. Place in /public/icons/: icon-192x192.png, icon-512x512.png, apple-touch-icon.png
3. Reference in manifest.json under "icons" array
4. Add to app/layout.tsx: appleWebApp config + <link rel="apple-touch-icon"> in head
5. The apple-touch-icon link tag is what iOS needs — missing this causes generic screenshot icon
6. Tell Claude Code: "Wire icon-192x192.png, icon-512x512.png, apple-touch-icon.png from /public/icons/ into manifest.json and app/layout.tsx"

---

## Phase 1 Build Instructions (Start Here in Claude Code)

### Folder Structure
prometheus/
├── app/
│   ├── page.tsx                   ← Search bar homepage
│   ├── search/page.tsx            ← Results page
│   └── api/
│       ├── search/route.ts        ← Main search API route
│       └── youtube/route.ts       ← YouTube fetch route
├── components/
│   ├── SearchBar.tsx
│   ├── ResultsGrid.tsx
│   ├── VideoCard.tsx
│   └── AISummary.tsx
└── lib/
    ├── claude.ts                  ← Claude API helper
    └── youtube.ts                 ← YouTube API helper

### .env.local Required Keys
YOUTUBE_API_KEY=your_key_here
ANTHROPIC_API_KEY=your_key_here
(Get YouTube key at console.cloud.google.com → Enable YouTube Data API v3 → Credentials → Create API Key)

### Claude Code Prompt Sequence (Phase 1)
Prompt 1: "Create a Next.js 14 app with TypeScript and Tailwind called Prometheus. The homepage has a centered search bar, mobile-first layout. On submit it navigates to /search?q=[query]. No hover-only interactions — all interactive elements must have onClick/tap handlers."

Prompt 2: "Create a Next.js API route at /api/youtube that takes a query param, calls the YouTube Data API v3 search endpoint, and returns the top 5 video results with videoId, title, channelName, and thumbnailUrl."

Prompt 3: "Create a Next.js API route at /api/search that takes a query, calls the YouTube route in parallel with a Claude API call. Claude receives the query and YouTube results and returns a 3-5 sentence summary. Return both to the client."

Prompt 4: "Create a SearchResults page that calls /api/search, shows the Claude summary at the top, then renders VideoCard components below. Each VideoCard embeds the YouTube iframe player. Mobile-first layout, single column mobile, grid desktop. Every interactive element needs both hover state and onClick/tap handler."

### Phase 2 (After Phase 1 Working)
- Add Reddit: hit https://www.reddit.com/search.json?q=[query] (no key needed)
- Add Articles: rss2json.com free RSS-to-JSON service
- Add Images: Unsplash API (free key at unsplash.com/developers)
- Build RedditCard, ArticleCard, ImageCard components one at a time

### Phase 3 (After Results Page Solid)
- Supabase Auth (magic link login)
- search_history table: user_id, query, timestamp
- Inject last 10 searches into Claude prompt as context

### Phase 4 (After Memory Works)
- /feed page: fetch top 5 interest tags, run parallel searches, render card feed

### Phase 5
- Save & Collections (Supabase)

### Phase 6
- Manual Graph (simplified node builder for non-RA-H users)

### Phase 7
- RA-H MCP integration

### Phase 8
- Settings + transparency panel

---

## Key Claude Code Habits
- One file/component per prompt — never give too large a scope
- Always specify mobile AND desktop layout in every component prompt
- Always end prompts with: "Every interactive element must have both a hover state for desktop and an onClick/tap handler for mobile. No functionality should be hover-only."
- Commit after each working piece before moving on
- Watch for hover-only interactions Claude Code generates by default',NULL,NULL,NULL,'not_chunked');
INSERT OR IGNORE INTO nodes (id,title,description,notes,link,event_date,created_at,updated_at,metadata,chunk,embedding,embedding_updated_at,embedding_text,chunk_status) VALUES (22,'Philosophy','Active interest domain — hub for stoicism, existentialism, ethics, and philosophy of mind. Fuels Braddon''s rap writing, game narrative design, wellness mindset, and AI ethics thinking.','Key branches:
- Stoicism (Marcus Aurelius, Epictetus, Seneca) — mindset, resilience, control
- Existentialism (Sartre, Camus, Nietzsche) — meaning-making, creative identity
- Ethics & moral philosophy — feeds game narrative design and character depth
- Philosophy of mind — connects to AI research and consciousness discussions
- Eastern philosophy (Taoism, Zen) — overlaps with wellness and flow states

Cross-domain connections:
- Rap writing: philosophical themes as lyrical frameworks and metaphors
- Game dev: moral dilemmas, NPC ethics, narrative weight
- Wellness: stoic daily practices, journaling, emotional regulation
- AI & Tech: philosophy of mind, consciousness, ethics of AI
- Prometheus content sources: Stanford Encyclopedia of Philosophy, Philosophy Bro, Partially Examined Life podcast, Daily Stoic',NULL,NULL,'2026-03-16T23:49:58.099Z','2026-03-16T23:49:58.099Z','{}','Philosophy

Active interest domain — hub for stoicism, existentialism, ethics, and philosophy of mind. Fuels Braddon''s rap writing, game narrative design, wellness mindset, and AI ethics thinking.

Key branches:
- Stoicism (Marcus Aurelius, Epictetus, Seneca) — mindset, resilience, control
- Existentialism (Sartre, Camus, Nietzsche) — meaning-making, creative identity
- Ethics & moral philosophy — feeds game narrative design and character depth
- Philosophy of mind — connects to AI research and consciousness discussions
- Eastern philosophy (Taoism, Zen) — overlaps with wellness and flow states

Cross-domain connections:
- Rap writing: philosophical themes as lyrical frameworks and metaphors
- Game dev: moral dilemmas, NPC ethics, narrative weight
- Wellness: stoic daily practices, journaling, emotional regulation
- AI & Tech: philosophy of mind, consciousness, ethics of AI
- Prometheus content sources: Stanford Encyclopedia of Philosophy, Philosophy Bro, Partially Examined Life podcast, Daily Stoic',NULL,NULL,NULL,'not_chunked');
INSERT OR IGNORE INTO nodes (id,title,description,notes,link,event_date,created_at,updated_at,metadata,chunk,embedding,embedding_updated_at,embedding_text,chunk_status) VALUES (23,'Comics & Superhero Universes','Active interest domain — Marvel and DC comics and cinematic universes. Informs Braddon''s game design storytelling, Stridemon creature lore, rap imagery, and the Huge Papa Multiverse project concept.','Key interests:
- Marvel: MCU storytelling, character arcs, multiverse lore, X-Men, Spider-Man, cosmic storylines
- DC: Batman psychology, Justice League dynamics, Elseworlds/alternate universes, Vertigo imprint
- Cross-universe: superhero origin structures, power system design, villain motivation depth

Cross-domain connections:
- Game dev: visual storytelling, character design, power systems, faction/lore architecture
- Stridemon: creature origin stories, power hierarchies, rival factions, comic-style lore writing
- Rap writing: hero/villain archetypes, cinematic imagery, epic narrative voice
- YouTube (Nerdforce): potential MCU/DC analysis content as cross-niche expansion
- Philosophy: ethics of heroism, moral gray areas, identity (alter ego as existential metaphor)
- Huge Papa Multiverse app idea: treat all personal projects as a connected comic universe',NULL,NULL,'2026-03-16T23:50:06.430Z','2026-03-16T23:50:06.430Z','{}','Comics & Superhero Universes

Active interest domain — Marvel and DC comics and cinematic universes. Informs Braddon''s game design storytelling, Stridemon creature lore, rap imagery, and the Huge Papa Multiverse project concept.

Key interests:
- Marvel: MCU storytelling, character arcs, multiverse lore, X-Men, Spider-Man, cosmic storylines
- DC: Batman psychology, Justice League dynamics, Elseworlds/alternate universes, Vertigo imprint
- Cross-universe: superhero origin structures, power system design, villain motivation depth

Cross-domain connections:
- Game dev: visual storytelling, character design, power systems, faction/lore architecture
- Stridemon: creature origin stories, power hierarchies, rival factions, comic-style lore writing
- Rap writing: hero/villain archetypes, cinematic imagery, epic narrative voice
- YouTube (Nerdforce): potential MCU/DC analysis content as cross-niche expansion
- Philosophy: ethics of heroism, moral gray areas, identity (alter ego as existential metaphor)
- Huge Papa Multiverse app idea: treat all personal projects as a connected comic universe',NULL,NULL,NULL,'not_chunked');
INSERT OR IGNORE INTO nodes (id,title,description,notes,link,event_date,created_at,updated_at,metadata,chunk,embedding,embedding_updated_at,embedding_text,chunk_status) VALUES (24,'Google NotebookLM','Google''s AI-powered research assistant (powered by Gemini 3) that grounds responses in user-uploaded sources — a key competitor/complement to RA-H in the second-brain/knowledge tool space.','## What it is
Source-grounded AI research assistant using RAG (Retrieval Augmented Generation). Answers are based only on documents you upload — drastically reduces hallucinations. Powered by Gemini 3 as of March 2026.

## Key features
- Audio Overviews: converts uploaded docs into a podcast-style conversation between two AI hosts. Users can now "join" the conversation interactively.
- Video Overviews: AI-generated video summaries with narration and visual aids
- Deep Research: autonomous research agent — give it a topic, it creates a research plan, searches hundreds of sources, returns a citation-backed report
- Mind Maps: visual concept maps generated from your sources
- Slide Decks + Infographics: one-click presentation generation (exportable to PPTX)
- Data Tables: extracts and structures data from uploaded documents
- Quizzes + Flashcards: study tools generated from your sources

## Pricing
- Free tier available (basic features, 300 daily credits)
- NotebookLM Plus: included in Google One AI Premium plan (~$20/mo)
- Enterprise tier available via Google Cloud

## How it compares to RA-H
- NotebookLM: session-based, excels at ingesting EXTERNAL documents (PDFs, YouTube videos, articles, websites) and letting you query them
- RA-H: persistent knowledge graph tracking YOUR OWN thinking, connections, and projects over time
- They''re complementary: research in NotebookLM → save key insights as nodes in RA-H
- NotebookLM = intake tool; RA-H = synthesis and memory layer

## Relevance to Prometheus
- NotebookLM''s Deep Research feature is conceptually similar to what Prometheus aims to do with its feed pipeline
- Audio Overviews = a feature Prometheus could explore for its card types
- Competitive landscape: both are AI-powered personalized knowledge surfaces','https://notebooklm.google.com',NULL,'2026-03-16T23:57:38.971Z','2026-03-16T23:57:38.971Z','{}','Google NotebookLM

Google''s AI-powered research assistant (powered by Gemini 3) that grounds responses in user-uploaded sources — a key competitor/complement to RA-H in the second-brain/knowledge tool space.

## What it is
Source-grounded AI research assistant using RAG (Retrieval Augmented Generation). Answers are based only on documents you upload — drastically reduces hallucinations. Powered by Gemini 3 as of March 2026.

## Key features
- Audio Overviews: converts uploaded docs into a podcast-style conversation between two AI hosts. Users can now "join" the conversation interactively.
- Video Overviews: AI-generated video summaries with narration and visual aids
- Deep Research: autonomous research agent — give it a topic, it creates a research plan, searches hundreds of sources, returns a citation-backed report
- Mind Maps: visual concept maps generated from your sources
- Slide Decks + Infographics: one-click presentation generation (exportable to PPTX)
- Data Tables: extracts and structures data from uploaded documents
- Quizzes + Flashcards: study tools generated from your sources

## Pricing
- Free tier available (basic features, 300 daily credits)
- NotebookLM Plus: included in Google One AI Premium plan (~$20/mo)
- Enterprise tier available via Google Cloud

## How it compares to RA-H
- NotebookLM: session-based, excels at ingesting EXTERNAL documents (PDFs, YouTube videos, articles, websites) and letting you query them
- RA-H: persistent knowledge graph tracking YOUR OWN thinking, connections, and projects over time
- They''re complementary: research in NotebookLM → save key insights as nodes in RA-H
- NotebookLM = intake tool; RA-H = synthesis and memory layer

## Relevance to Prometheus
- NotebookLM''s Deep Research feature is conceptually similar to what Prometheus aims to do with its feed pipeline
- Audio Overviews = a feature Prometheus could explore for its card types
- Competitive landscape: both are AI-powered personalized knowledge surfaces',NULL,NULL,NULL,'not_chunked');
INSERT OR IGNORE INTO nodes (id,title,description,notes,link,event_date,created_at,updated_at,metadata,chunk,embedding,embedding_updated_at,embedding_text,chunk_status) VALUES (25,'Open Notebook — Setup Guide & Claude Code Integration','Self-hosted open-source NotebookLM alternative (github.com/lfnovo/open-notebook) — full setup guide covering Docker Compose install, Anthropic API key config, MCP server integration with Claude Code, and the full research-to-RA-H workflow.','## Quick Setup (Docker + Anthropic key)

### Step 1 — Pull the docker-compose file
```bash
curl -o docker-compose.yml https://raw.githubusercontent.com/lfnovo/open-notebook/main/docker-compose.yml
```

### Step 2 — Create docker.env
```env
ANTHROPIC_API_KEY=sk-ant-...
OPEN_NOTEBOOK_ENCRYPTION_KEY=some-secret-string
SURREAL_URL=ws://surrealdb:8000/rpc
SURREAL_USER=root
SURREAL_PASSWORD=root
SURREAL_NAMESPACE=open_notebook
SURREAL_DATABASE=open_notebook
```

### Step 3 — Launch
```bash
docker compose up -d
```
Access at http://localhost:8502. Wait 20-30s for startup.

### Free/local option
```bash
curl -o docker-compose.yml https://raw.githubusercontent.com/lfnovo/open-notebook/main/examples/docker-compose-ollama.yml
```

## Key features
- 16+ AI providers (Anthropic, OpenAI, Ollama, Groq free tier, etc.)
- Multi-modal: PDFs, videos, audio, web pages
- Multi-speaker podcast generation
- Full-text + vector search
- REST API on port 5055 (key for Claude Code integration)
- MCP server support for agentic access

## Integration with RA-H workflow
- Use as intake tool: research in Open Notebook → save key insights as RA-H nodes
- Open Notebook = external document intake; RA-H = persistent synthesis + memory layer



## Claude Code MCP Integration (added 2026-03-16)

### Path 1 — Open Notebook (self-hosted) → Claude Code
Open Notebook ships a built-in MCP server. Once your Docker instance is running on port 5055:

```bash
claude mcp add open-notebook uvx open-notebook-mcp
```

Or manually in ~/.claude/claude_mcp_config.json:
```json
{
  "mcpServers": {
    "open-notebook": {
      "command": "uvx",
      "args": ["open-notebook-mcp"],
      "env": {
        "OPEN_NOTEBOOK_URL": "http://localhost:5055",
        "OPEN_NOTEBOOK_PASSWORD": "your_password_here"
      }
    }
  }
}
```
Restart Claude Code. Now Claude can access notebooks, search content, create chat sessions, and generate notes directly.

### Path 2 — Google NotebookLM → Claude Code
```bash
claude mcp add notebooklm npx notebooklm-mcp@latest
```
Uses browser automation. Use a dedicated Google account, not your primary one.

### Full Power Workflow
```
Web/YouTube/PDF → Open Notebook (ingest + RAG)
       ↓
Claude Code (queries Open Notebook via MCP, synthesizes)
       ↓
RA-H graph (saves key insights as nodes)
       ↓
Prometheus / Command Center (surfaces everything)
```
Claude Code becomes the orchestrator — pulls research from Open Notebook, reasons over it, pushes distilled insights into RA-H, all in one session without tab-switching.



## Claude Code Integration via MCP

### Path 1 — Open Notebook (self-hosted) → Claude Code
Prerequisites: Open Notebook running (Docker, port 5055), uv installed, Claude Code installed.

One-liner install:
```bash
claude mcp add open-notebook uvx open-notebook-mcp
```

Or manually edit ~/.claude/claude_mcp_config.json:
```json
{
  "mcpServers": {
    "open-notebook": {
      "command": "uvx",
      "args": ["open-notebook-mcp"],
      "env": {
        "OPEN_NOTEBOOK_URL": "http://localhost:5055",
        "OPEN_NOTEBOOK_PASSWORD": "your_password_here"
      }
    }
  }
}
```
Restart Claude Code. Done.

### Path 2 — Google NotebookLM → Claude Code
```bash
claude mcp add notebooklm npx notebooklm-mcp@latest
```
Uses browser automation. Use a dedicated Google account, not your primary.

## Full Power Workflow
Web/YouTube/PDF → Open Notebook (ingest + RAG)
→ Claude Code (queries Open Notebook via MCP, synthesizes)
→ RA-H graph (saves key insights as nodes)
→ Prometheus / Command Center (surfaces everything)

Claude Code becomes the orchestrator: pulls research from Open Notebook, reasons over it, pushes distilled insights into RA-H — all in one session without tab switching.



## Live Installation on Bradd''s Machine (2026-03-17)

### Files created
- `C:/Users/bradd/open-notebook/docker-compose.yml` — official compose config, modified to load `docker.env` via `env_file`
- `C:/Users/bradd/open-notebook/docker.env` — contains ANTHROPIC_API_KEY and generated OPEN_NOTEBOOK_ENCRYPTION_KEY
- Data volumes: `./surreal_data` (SurrealDB) and `./notebook_data` (notebooks)

### Confirmed running
- `open-notebook-open_notebook-1` on ports 8502 (UI) and 5055 (API)
- `open-notebook-surrealdb-1` on port 8000
- Access at http://localhost:8502

### Docker Desktop troubleshooting encountered
- Docker CLI was installed but Docker Desktop daemon wasn''t running
- WSL2 was not installed — required `wsl --install` from elevated PowerShell, then reboot
- After WSL install + reboot, Docker Desktop had a WSL proxy error: `Permission denied` on `docker-desktop-user-distro`
- Fix: kill all Docker processes (`taskkill /F /IM "Docker Desktop.exe" /T`), run `wsl --shutdown`, relaunch Docker Desktop
- `docker compose up -d` succeeded after Docker Desktop was stable

### docker-compose modification
The official compose has OPEN_NOTEBOOK_ENCRYPTION_KEY inline. Modified to move secrets to `docker.env`:
```yaml
open_notebook:
  env_file:
    - docker.env
  environment:
    - SURREAL_URL=ws://surrealdb:8000/rpc
    ...
```','https://github.com/lfnovo/open-notebook',NULL,'2026-03-17T00:01:16.562Z','2026-03-17T00:38:05.640Z','{}','Open Notebook — Setup Guide & Claude Code Integration

Self-hosted open-source NotebookLM alternative (github.com/lfnovo/open-notebook) — setup guide covering Docker Compose install, API key config, and integration with Claude Code via MCP.

## Quick Setup (Docker + Anthropic key)

### Step 1 — Pull the docker-compose file
```bash
curl -o docker-compose.yml https://raw.githubusercontent.com/lfnovo/open-notebook/main/docker-compose.yml
```

### Step 2 — Create docker.env
```env
ANTHROPIC_API_KEY=sk-ant-...
OPEN_NOTEBOOK_ENCRYPTION_KEY=some-secret-string
SURREAL_URL=ws://surrealdb:8000/rpc
SURREAL_USER=root
SURREAL_PASSWORD=root
SURREAL_NAMESPACE=open_notebook
SURREAL_DATABASE=open_notebook
```

### Step 3 — Launch
```bash
docker compose up -d
```
Access at http://localhost:8502. Wait 20-30s for startup.

### Free/local option
```bash
curl -o docker-compose.yml https://raw.githubusercontent.com/lfnovo/open-notebook/main/examples/docker-compose-ollama.yml
```

## Key features
- 16+ AI providers (Anthropic, OpenAI, Ollama, Groq free tier, etc.)
- Multi-modal: PDFs, videos, audio, web pages
- Multi-speaker podcast generation
- Full-text + vector search
- REST API on port 5055 (key for Claude Code integration)
- MCP server support for agentic access

## Integration with RA-H workflow
- Use as intake tool: research in Open Notebook → save key insights as RA-H nodes
- Open Notebook = external document intake; RA-H = persistent synthesis + memory layer',NULL,NULL,NULL,'not_chunked');
INSERT OR IGNORE INTO nodes (id,title,description,notes,link,event_date,created_at,updated_at,metadata,chunk,embedding,embedding_updated_at,embedding_text,chunk_status) VALUES (26,'Consumption Workflow — Making Knowledge Intake Effortless','Personal knowledge consumption strategy for Braddon — maps how Open Notebook, Prometheus, RA-H, and Stridemon combine to turn passive daily activities into automatic knowledge capture across all domains.','## Core Principle
Don''t consume MORE — make what you already consume STICK and feed back into your projects automatically. Open Notebook + RA-H is the membrane that catches everything valuable and routes it where it needs to go.

## The Three Layers
1. INTAKE — Open Notebook (raw outside world content comes in)
2. SYNTHESIS — RA-H Graph + Claude Code (your thinking lives here)
3. SURFACING — Prometheus + Command Center (knowledge comes back in useful formats)

## Key Consumption Windows

### Walking (highest leverage — zero extra time cost)
Stridemon walks = untapped audio time. Every night or morning, have Open Notebook generate a 5-10 min Audio Overview from whatever was added to a notebook that week. Put in AirPods, open Stridemon, walk, passively absorb curated knowledge while earning coins.
Domains: philosophy texts, Rocket League strategy, Godot devlogs, MCU lore, rap technique essays.

### During builds (Prometheus side tab)
Prometheus running in a side tab while coding = scrollable card feed tuned to your interests instead of doom-scrolling. "Add to Brain" button sends anything good directly to RA-H. Zero friction capture.

### YouTube (already happening — just add one step)
Already watching RL, Godot, AI content. After videos that matter: paste URL into Open Notebook → chat with transcript → key insight → RA-H node. No change to how you watch, just one capture step after.
Bonus: use Open Notebook to research video topics BEFORE filming for Nerdforce.

### Comics + Philosophy (podcast treatment)
Dense material (Nietzsche, Batman lore, Stoic texts) = hard to read, easy to listen to. Open Notebook podcast gen turns any PDF/article into a conversational audio breakdown. Generate once → listen on walk → key insight → RA-H node.

## The One-Tap Capture Rule
Biggest killer = friction of saving insights. Fix: Claude Code + Open Notebook MCP makes capture a single prompt:
"Save this to my graph: stoicism teaches you control response not circumstance — connects to rap writing and wellness"
Claude Code writes the node, assigns dimensions, creates edges. 3 minutes → 10 seconds.

## Minimum Viable Daily Routine
- Morning walk: Audio Overview of last week''s notebook adds (Open Notebook)
- During builds: scrolling feed (Prometheus)
- After good YouTube video: paste URL, extract insight (Open Notebook → RA-H)
- Random thought/idea: voice-style prompt (Claude Code → RA-H)
- Before bed: Prometheus session summary → tap "Add to Brain" (Prometheus → RA-H)

## Per-Domain Specifics
- Godot: upload GDQuest tutorials, devlog articles, Godot docs → chat while building → best insights → RA-H
- Rocket League/Nerdforce: upload SunlessKhan/Musty transcripts, pro match summaries → podcast for walks → strategy insight → Content Brain video idea
- Rap: upload Genius lyrics, poetry analysis, philosophy texts → "what''s the connection between Camus and this Kendrick verse?" → node linking Comics + Philosophy + Rap
- Philosophy: Audio Overview of dense texts on walks → 3 actionable ideas → RA-H node
- Comics: upload comic scripts, MCU wiki pages → lore connections to Stridemon design → RA-H node
- Stridemon: Open Notebook as lore bible assistant — feed it art style guide + comic world-building refs → cited design answers',NULL,NULL,'2026-03-17T00:42:20.314Z','2026-03-17T00:42:20.314Z','{}','Consumption Workflow — Making Knowledge Intake Effortless

Personal knowledge consumption strategy for Braddon — maps how Open Notebook, Prometheus, RA-H, and Stridemon combine to turn passive daily activities into automatic knowledge capture across all domains.

## Core Principle
Don''t consume MORE — make what you already consume STICK and feed back into your projects automatically. Open Notebook + RA-H is the membrane that catches everything valuable and routes it where it needs to go.

## The Three Layers
1. INTAKE — Open Notebook (raw outside world content comes in)
2. SYNTHESIS — RA-H Graph + Claude Code (your thinking lives here)
3. SURFACING — Prometheus + Command Center (knowledge comes back in useful formats)

## Key Consumption Windows

### Walking (highest leverage — zero extra time cost)
Stridemon walks = untapped audio time. Every night or morning, have Open Notebook generate a 5-10 min Audio Overview from whatever was added to a notebook that week. Put in AirPods, open Stridemon, walk, passively absorb curated knowledge while earning coins.
Domains: philosophy texts, Rocket League strategy, Godot devlogs, MCU lore, rap technique essays.

### During builds (Prometheus side tab)
Prometheus running in a side tab while coding = scrollable card feed tuned to your interests instead of doom-scrolling. "Add to Brain" button sends anything good directly to RA-H. Zero friction capture.

### YouTube (already happening — just add one step)
Already watching RL, Godot, AI content. After videos that matter: paste URL into Open Notebook → chat with transcript → key insight → RA-H node. No change to how you watch, just one capture step after.
Bonus: use Open Notebook to research video topics BEFORE filming for Nerdforce.

### Comics + Philosophy (podcast treatment)
Dense material (Nietzsche, Batman lore, Stoic texts) = hard to read, easy to listen to. Open Notebook podcast gen turns any PDF/article into a conversational audio breakdown. Generate once → listen on walk → key insight → RA-H node.

## The One-Tap Capture Rule
Biggest killer = friction of saving insights. Fix: Claude Code + Open Notebook MCP makes capture a single prompt:
"Save this to my graph: stoicism teaches you control response not circumstance — connects to rap writing and wellness"
Claude Code writes the node, assigns dimensions, creates edges. 3 minutes → 10 seconds.

## Minimum Viable Daily Routine
- Morning walk: Audio Overview of last week''s notebook adds (Open Notebook)
- During builds: scrolling feed (Prometheus)
- After good YouTube video: paste URL, extract insight (Open Notebook → RA-H)
- Random thought/idea: voice-style prompt (Claude Code → RA-H)
- Before bed: Prometheus session summary → tap "Add to Brain" (Prometheus → RA-H)

## Per-Domain Specifics
- Godot: upload GDQuest tutorials, devlog articles, Godot docs → chat while building → best insights → RA-H
- Rocket League/Nerdforce: upload SunlessKhan/Musty transcripts, pro match summaries → podcast for walks → strategy insight → Content Brain video idea
- Rap: upload Genius lyrics, poetry analysis, philosophy texts → "what''s the connection between Camus and this Kendrick verse?" → node linking Comics + Philosophy + Rap
- Philosophy: Audio Overview of dense texts on walks → 3 actionable ideas → RA-H node
- Comics: upload comic scripts, MCU wiki pages → lore connections to Stridemon design → RA-H node
- Stridemon: Open Notebook as lore bible assistant — feed it art style guide + comic world-building refs → cited design answers',NULL,NULL,NULL,'not_chunked');
INSERT OR IGNORE INTO nodes (id,title,description,notes,link,event_date,created_at,updated_at,metadata,chunk,embedding,embedding_updated_at,embedding_text,chunk_status) VALUES (27,'Build vs Consume — Priority Decision (March 2026)','Strategic prioritization note — establishes why consuming and filling RA-H graph must come before building more apps, and the correct sequence: Open Notebook setup → consumption habit → Prometheus Phase 2 → Command Center.','## Decision: Consume First, Build Second

### Why not Prometheus yet
Phase 1 already works (search bar, YouTube, Claude summaries). Phase 2-4 add real value but won''t feel meaningful until the RA-H graph has actual knowledge depth. Building the surfacing layer before the knowledge layer has content = shallow results.

### Why not just consume without structure
Consuming without Open Notebook + RA-H = knowledge evaporates. The system needs to be in place first.

### The Real Bottleneck
Open Notebook not set up yet. Everything depends on this. Claude Code handles the install.

### Correct Sequence
1. Set up Open Notebook (this week, ~30 mins via Claude Code)
2. Start consumption habit — walks + Audio Overviews
3. Let RA-H graph fill up with real insights (1-2 weeks)
4. Prometheus Phase 2 (Reddit + Articles cards)
5. Prometheus Phase 3 (auth + memory)
6. Command Center — by now graph is rich enough to be worth surfacing

### Why Consuming Wins Right Now
- RA-H graph is thin (26 nodes, mostly project docs not real knowledge)
- Command Center, Content Brain, Huge Papa Multiverse all pull from RA-H as their database
- A thin graph = shallow app experiences from day one
- 2-3 weeks of consumption = dramatically more powerful apps

### The Trap to Avoid
Building more apps on a thin graph. Construct the knowledge layer before the surfacing layer.',NULL,NULL,'2026-03-17T00:45:20.682Z','2026-03-17T00:45:20.682Z','{}','Build vs Consume — Priority Decision (March 2026)

Strategic prioritization note — establishes why consuming and filling RA-H graph must come before building more apps, and the correct sequence: Open Notebook setup → consumption habit → Prometheus Phase 2 → Command Center.

## Decision: Consume First, Build Second

### Why not Prometheus yet
Phase 1 already works (search bar, YouTube, Claude summaries). Phase 2-4 add real value but won''t feel meaningful until the RA-H graph has actual knowledge depth. Building the surfacing layer before the knowledge layer has content = shallow results.

### Why not just consume without structure
Consuming without Open Notebook + RA-H = knowledge evaporates. The system needs to be in place first.

### The Real Bottleneck
Open Notebook not set up yet. Everything depends on this. Claude Code handles the install.

### Correct Sequence
1. Set up Open Notebook (this week, ~30 mins via Claude Code)
2. Start consumption habit — walks + Audio Overviews
3. Let RA-H graph fill up with real insights (1-2 weeks)
4. Prometheus Phase 2 (Reddit + Articles cards)
5. Prometheus Phase 3 (auth + memory)
6. Command Center — by now graph is rich enough to be worth surfacing

### Why Consuming Wins Right Now
- RA-H graph is thin (26 nodes, mostly project docs not real knowledge)
- Command Center, Content Brain, Huge Papa Multiverse all pull from RA-H as their database
- A thin graph = shallow app experiences from day one
- 2-3 weeks of consumption = dramatically more powerful apps

### The Trap to Avoid
Building more apps on a thin graph. Construct the knowledge layer before the surfacing layer.',NULL,NULL,NULL,'not_chunked');
INSERT OR IGNORE INTO nodes (id,title,description,notes,link,event_date,created_at,updated_at,metadata,chunk,embedding,embedding_updated_at,embedding_text,chunk_status) VALUES (28,'Content Capture — Getting Stuff into Open Notebook','Reference guide for all methods of getting YouTube videos, articles, PDFs, and other content into Open Notebook — ranked by friction level with per-domain notebook structure for Braddon''s interests.','## Methods Ranked by Friction (Low → High)

### Method 1 — Paste YouTube URL directly (easiest)
Open Notebook natively extracts YouTube transcripts automatically.
1. Open localhost:8502
2. Open or create a notebook
3. Click Add Source → paste YouTube URL
4. Done — transcript extracted, embedded, searchable, chat-able
Note: ~40% of YouTube URLs fail or stall. Backup = Method 4.

### Method 2 — Paste any web URL
Works for any web page, article, Reddit thread, blog post, news article.
Same flow: Add Source → paste URL → content extracted automatically.
Covers: Hacker News, Reddit, Daily Stoic, CBR, devlogs, all Prometheus sources.

### Method 3 — Upload a file
Supports: PDF, EPUB, Word, PowerPoint, Excel, TXT, Markdown, MP3, WAV, MP4, AVI, images (OCR), ZIP.
For philosophy PDFs, game design papers, podcast audio — drag and drop.
Audio/video files are auto-transcribed.

### Method 4 — Manual transcript paste (bulletproof YouTube backup)
When URL import fails:
1. YouTube video → click "..." → Show transcript
2. Click three dots in transcript panel → Toggle timestamps OFF
3. Select all, copy
4. Open Notebook → Add Source → Text → paste
Takes 30 seconds, works 100% of the time.

### Method 5 — Via Claude Code MCP (zero UI)
Once MCP is wired up, from Claude Code session:
"Add this YouTube video to my Philosophy notebook: youtube.com/watch?v=..."
Claude Code calls Open Notebook API directly — no browser, no UI.

## Recommended Notebook Structure
- Rocket League: SunlessKhan/Musty/Lethamyr videos, strategy articles, pro match analysis
- Game Dev: Godot tutorials, GDQuest videos, itch.io devlogs, design articles
- Philosophy: Stoic texts, lecture videos, Partially Examined Life episodes
- Comics & Lore: MCU/DC wikis, character analysis videos, comic event summaries
- Rap & Writing: Genius breakdowns, poetry analysis, technique videos
- AI & Tech: Hacker News, Anthropic blog, AI research videos
- Stridemon: Art style guide, creature lore docs, comic world-building refs

## Key Tip
Name transcript files descriptively before uploading:
"sunlesskhan-how-to-rotate-2025.txt" rather than "transcript.txt"
Open Notebook uses filenames in citations — good names = better context.',NULL,NULL,'2026-03-17T00:47:24.281Z','2026-03-17T00:47:24.281Z','{}','Content Capture — Getting Stuff into Open Notebook

Reference guide for all methods of getting YouTube videos, articles, PDFs, and other content into Open Notebook — ranked by friction level with per-domain notebook structure for Braddon''s interests.

## Methods Ranked by Friction (Low → High)

### Method 1 — Paste YouTube URL directly (easiest)
Open Notebook natively extracts YouTube transcripts automatically.
1. Open localhost:8502
2. Open or create a notebook
3. Click Add Source → paste YouTube URL
4. Done — transcript extracted, embedded, searchable, chat-able
Note: ~40% of YouTube URLs fail or stall. Backup = Method 4.

### Method 2 — Paste any web URL
Works for any web page, article, Reddit thread, blog post, news article.
Same flow: Add Source → paste URL → content extracted automatically.
Covers: Hacker News, Reddit, Daily Stoic, CBR, devlogs, all Prometheus sources.

### Method 3 — Upload a file
Supports: PDF, EPUB, Word, PowerPoint, Excel, TXT, Markdown, MP3, WAV, MP4, AVI, images (OCR), ZIP.
For philosophy PDFs, game design papers, podcast audio — drag and drop.
Audio/video files are auto-transcribed.

### Method 4 — Manual transcript paste (bulletproof YouTube backup)
When URL import fails:
1. YouTube video → click "..." → Show transcript
2. Click three dots in transcript panel → Toggle timestamps OFF
3. Select all, copy
4. Open Notebook → Add Source → Text → paste
Takes 30 seconds, works 100% of the time.

### Method 5 — Via Claude Code MCP (zero UI)
Once MCP is wired up, from Claude Code session:
"Add this YouTube video to my Philosophy notebook: youtube.com/watch?v=..."
Claude Code calls Open Notebook API directly — no browser, no UI.

## Recommended Notebook Structure
- Rocket League: SunlessKhan/Musty/Lethamyr videos, strategy articles, pro match analysis
- Game Dev: Godot tutorials, GDQuest videos, itch.io devlogs, design articles
- Philosophy: Stoic texts, lecture videos, Partially Examined Life episodes
- Comics & Lore: MCU/DC wikis, character analysis videos, comic event summaries
- Rap & Writing: Genius breakdowns, poetry analysis, technique videos
- AI & Tech: Hacker News, Anthropic blog, AI research videos
- Stridemon: Art style guide, creature lore docs, comic world-building refs

## Key Tip
Name transcript files descriptively before uploading:
"sunlesskhan-how-to-rotate-2025.txt" rather than "transcript.txt"
Open Notebook uses filenames in citations — good names = better context.',NULL,NULL,NULL,'not_chunked');
INSERT OR IGNORE INTO nodes (id,title,description,notes,link,event_date,created_at,updated_at,metadata,chunk,embedding,embedding_updated_at,embedding_text,chunk_status) VALUES (29,'Open Notebook Clipper — Chrome Extension','Built and live Chrome extension that sends any browser tab (YouTube, articles, Reddit) to Open Notebook with one click — auto-suggests notebook based on URL pattern, posts to localhost:5055 API.','## What it does
One-click capture of any browser tab → sends to Open Notebook instantly.
No copy-paste, no tab switching, zero friction.

## Flow
1. User clicks extension icon
2. Popup shows detected page type + auto-suggested notebook
3. User confirms notebook → clicks Send
4. Extension POSTs current URL to Open Notebook API (localhost:5055)
5. Open Notebook handles transcript/content extraction automatically
6. Extension shows ✅ Added to [Notebook]

## Files (3 total — same pattern as grocery-tracker extension)
- manifest.json (MV3)
- popup.html (notebook picker UI + send button + status)
- popup.js (fetch notebooks, detect page, POST to API)

## API Calls
- GET localhost:5055/api/v1/notebook → fetch notebook list for dropdown
- POST localhost:5055/api/v1/source → send URL + notebook_id

## Smart Notebook Auto-Detection
Maps domains/paths to notebooks automatically:
- youtube.com → detect from video title keywords
- reddit.com/r/RocketLeague → Rocket League
- reddit.com/r/godot → Game Dev
- reddit.com/r/philosophy → Philosophy
- reddit.com/r/Marvel or /r/DCcomics → Comics & Lore
- news.ycombinator.com → AI & Tech
- dailystoic.com, philosophybro.com → Philosophy
- cbr.com, screenrant.com/comics → Comics & Lore

## Settings
- Configurable API URL (default localhost:5055) saved to chrome.storage.local
- Optional note/tag field before sending

## Claude Code Prompt Sequence
Prompt 1: Build base extension — manifest, popup.html, popup.js with notebook fetch + URL POST + status message
Prompt 2: Add smart auto-detection by domain/URL pattern
Prompt 3: Add optional note field + settings page with configurable API URL

## Connection to ecosystem
- Same architecture as grocery-tracker Chrome extension (grab page → POST to backend)
- Feeds directly into Open Notebook → RA-H consumption workflow
- Eliminates the last remaining friction point in the intake pipeline



## Corrected API Endpoints (2026-03-17)
No /v1/ prefix. Correct endpoints:
- GET localhost:5055/api/notebooks → array with `id` and `name` fields (not `title`)
- POST localhost:5055/api/sources/json → JSON endpoint (/api/sources requires multipart/form-data)

Required POST body: { type: ''link'', url, notebooks: [id], async_processing: true }
`type` is required — omitting it returns 422.

## Final File List
- manifest.json — MV3, icons at icons/icon16/48/128.png
- popup.html — dark UI, 320px
- popup.js — parallel init, 5-min notebook cache via chrome.storage.local
- settings.html + settings.js — configurable API URL
- icons/ — generated via Node.js zlib PNG (purple page icon)

## Optimizations
- Notebook list cached in chrome.storage.local (5 min TTL)
- getStorage + chrome.tabs.query run in parallel via Promise.all
- async_processing: true for instant popup response

## Load in Chrome
chrome://extensions → Developer Mode → Load Unpacked → C:/Users/bradd/open-notebook-clipper
After code changes: click refresh on the extension card



## Status: BUILT AND LIVE (March 17, 2026)
Extension is installed and working in Chrome.
Loaded via chrome://extensions → Developer Mode → Load Unpacked.
Pinned to Chrome toolbar.

## Files built by Claude Code
- manifest.json (MV3, permissions: activeTab, scripting, storage)
- popup.html (320px, notebook dropdown, URL display, Send button, status message, gear icon)
- popup.js (fetches notebooks from localhost:5055, auto-suggests by URL pattern, POSTs source)
- settings.html + settings.js (configurable API URL saved to chrome.storage.local)

## Auto-suggestion rules implemented
- youtube.com + godot/unity keywords → Game Dev
- youtube.com + RL keywords → Rocket League
- reddit.com/r/RocketLeague → Rocket League
- reddit.com/r/godot → Game Dev
- reddit.com/r/philosophy → Philosophy
- reddit.com/r/Marvel or /r/DCcomics → Comics & Lore
- news.ycombinator.com → AI & Tech
- dailystoic.com → Philosophy
- cbr.com → Comics & Lore
- default → first notebook in list

## API
- GET localhost:5055/api/v1/notebook (fetch notebook list)
- POST localhost:5055/api/v1/source (send URL + notebook_id)',NULL,NULL,'2026-03-17T00:51:07.127Z','2026-03-17T18:32:54.761Z','{}','Open Notebook Clipper — Chrome Extension

Chrome extension project — one-click sender that captures the current tab (YouTube URL, article, Reddit thread) and posts it directly to Open Notebook''s local API, with smart notebook auto-detection based on domain/URL patterns.

## What it does
One-click capture of any browser tab → sends to Open Notebook instantly.
No copy-paste, no tab switching, zero friction.

## Flow
1. User clicks extension icon
2. Popup shows detected page type + auto-suggested notebook
3. User confirms notebook → clicks Send
4. Extension POSTs current URL to Open Notebook API (localhost:5055)
5. Open Notebook handles transcript/content extraction automatically
6. Extension shows ✅ Added to [Notebook]

## Files (3 total — same pattern as grocery-tracker extension)
- manifest.json (MV3)
- popup.html (notebook picker UI + send button + status)
- popup.js (fetch notebooks, detect page, POST to API)

## API Calls
- GET localhost:5055/api/v1/notebook → fetch notebook list for dropdown
- POST localhost:5055/api/v1/source → send URL + notebook_id

## Smart Notebook Auto-Detection
Maps domains/paths to notebooks automatically:
- youtube.com → detect from video title keywords
- reddit.com/r/RocketLeague → Rocket League
- reddit.com/r/godot → Game Dev
- reddit.com/r/philosophy → Philosophy
- reddit.com/r/Marvel or /r/DCcomics → Comics & Lore
- news.ycombinator.com → AI & Tech
- dailystoic.com, philosophybro.com → Philosophy
- cbr.com, screenrant.com/comics → Comics & Lore

## Settings
- Configurable API URL (default localhost:5055) saved to chrome.storage.local
- Optional note/tag field before sending

## Claude Code Prompt Sequence
Prompt 1: Build base extension — manifest, popup.html, popup.js with notebook fetch + URL POST + status message
Prompt 2: Add smart auto-detection by domain/URL pattern
Prompt 3: Add optional note field + settings page with configurable API URL

## Connection to ecosystem
- Same architecture as grocery-tracker Chrome extension (grab page → POST to backend)
- Feeds directly into Open Notebook → RA-H consumption workflow
- Eliminates the last remaining friction point in the intake pipeline',NULL,NULL,NULL,'not_chunked');
INSERT OR IGNORE INTO nodes (id,title,description,notes,link,event_date,created_at,updated_at,metadata,chunk,embedding,embedding_updated_at,embedding_text,chunk_status) VALUES (30,'Claude Interaction Preferences','Bradd''s preferred shorthand and workflow conventions when working with Claude and RA-H — saves typing and speeds up sessions.','## Shorthands\n- `rah` = ra-h (the personal knowledge graph MCP server) — accept both forms interchangeably',NULL,NULL,'2026-03-17T01:10:38.307Z','2026-03-17T01:10:38.307Z','{}','Claude Interaction Preferences

Bradd''s preferred shorthand and workflow conventions when working with Claude and RA-H — saves typing and speeds up sessions.

## Shorthands\n- `rah` = ra-h (the personal knowledge graph MCP server) — accept both forms interchangeably',NULL,NULL,NULL,'not_chunked');
INSERT OR IGNORE INTO nodes (id,title,description,notes,link,event_date,created_at,updated_at,metadata,chunk,embedding,embedding_updated_at,embedding_text,chunk_status) VALUES (31,'What To Do With Open Notebook — Usage Guide','Reference guide — five concrete ways to use Open Notebook notebooks once filled with sources, mapped to Braddon''s specific domains and connected to the full RA-H → Prometheus output pipeline.','## Core Mental Model
Notebooks aren''t a destination — they''re a processing layer.
Content goes in → wisdom comes out → wisdom lives permanently in RA-H → every tool you build accesses it.

## The 5 Things You Do With a Notebook

### 1. Chat with your sources
Ask questions, get cited answers — from YOUR content only, no hallucinations.
Examples by domain:
- Rocket League: "What are the most common mistakes Diamond players make in rotation?" → pulls from SunlessKhan/Musty transcripts
- Philosophy: "What would Marcus Aurelius say about dealing with a losing streak?" → synthesizes Meditations + Daily Stoic + lecture transcripts
- Stridemon: "Does this creature power fit the established power hierarchy?" → checks art style guide + lore docs
- Game Dev: "How does GDQuest handle state machines in Godot 4?" → pulls from tutorial transcripts

### 2. Generate Audio Overviews for walks
Hit Generate Audio Overview → 5-15 min conversational AI podcast about your notebook content.
AirPods + Stridemon walk + notebook audio = passive absorption with zero extra time cost.
One notebook = one walk = meaningful retention.

### 3. Extract insights → push to RA-H
The bridge between Open Notebook and the knowledge graph.
After chatting, capture valuable insights:
- Via Claude Code MCP: "Save this to my RA-H graph: [insight]. Connect to Philosophy and Rap nodes."
- Manually: create RA-H node, tag it, wire edges
This is how the graph goes from 30 project-doc nodes to hundreds of real insight nodes.

### 4. Generate content directly
- Nerdforce scripts: feed 5 pro match analysis sources → "give me a video script angle on X" → done in 2 minutes
- Rap writing prompts: Philosophy + Rap notebook → "5 metaphor angles connecting stoic resilience to competitive Rocket League"
- Stridemon lore: "Write an origin story for a water-type creature fitting our established comic-style lore" → cited against style guide
- Video research briefs: dump 3-5 sources into temp notebook → "summarize the most interesting talking points for a video about X"

### 5. Feed Prometheus automatically
Long-game payoff. RA-H insights extracted from Open Notebook surface as Prometheus cards:
- "You explored stoicism 2 weeks ago — here''s what''s new"
- "3 new Godot devlogs match your game dev interests"
- "Connection Drop: Batman''s psychology maps to your rap writing themes"

## The Daily Loop
Chrome Extension clips content → Open Notebook notebook
→ Chat / Audio Overview on walk
→ Best insights → RA-H nodes via Claude Code
→ Prometheus surfaces them + connects across domains
→ Used in Godot, rap, YouTube, Stridemon

## Notebook-Specific Use Cases
- Rocket League: chat for strategy, audio on walks, script fuel for Nerdforce
- Game Dev: chat while building, reference during coding sessions
- Philosophy: audio overviews on walks, lyrical fuel for rap, wellness mindset
- Comics & Lore: Stridemon creature design reference, rap imagery, video cross-niche
- Rap & Writing: creative prompts, lyrical connections, technique reference
- AI & Tech: Prometheus competitive research, trend awareness, graph enrichment
- Stridemon: lore bible assistant, design consistency checker',NULL,NULL,'2026-03-17T01:19:01.745Z','2026-03-17T01:19:01.745Z','{}','What To Do With Open Notebook — Usage Guide

Reference guide — five concrete ways to use Open Notebook notebooks once filled with sources, mapped to Braddon''s specific domains and connected to the full RA-H → Prometheus output pipeline.

## Core Mental Model
Notebooks aren''t a destination — they''re a processing layer.
Content goes in → wisdom comes out → wisdom lives permanently in RA-H → every tool you build accesses it.

## The 5 Things You Do With a Notebook

### 1. Chat with your sources
Ask questions, get cited answers — from YOUR content only, no hallucinations.
Examples by domain:
- Rocket League: "What are the most common mistakes Diamond players make in rotation?" → pulls from SunlessKhan/Musty transcripts
- Philosophy: "What would Marcus Aurelius say about dealing with a losing streak?" → synthesizes Meditations + Daily Stoic + lecture transcripts
- Stridemon: "Does this creature power fit the established power hierarchy?" → checks art style guide + lore docs
- Game Dev: "How does GDQuest handle state machines in Godot 4?" → pulls from tutorial transcripts

### 2. Generate Audio Overviews for walks
Hit Generate Audio Overview → 5-15 min conversational AI podcast about your notebook content.
AirPods + Stridemon walk + notebook audio = passive absorption with zero extra time cost.
One notebook = one walk = meaningful retention.

### 3. Extract insights → push to RA-H
The bridge between Open Notebook and the knowledge graph.
After chatting, capture valuable insights:
- Via Claude Code MCP: "Save this to my RA-H graph: [insight]. Connect to Philosophy and Rap nodes."
- Manually: create RA-H node, tag it, wire edges
This is how the graph goes from 30 project-doc nodes to hundreds of real insight nodes.

### 4. Generate content directly
- Nerdforce scripts: feed 5 pro match analysis sources → "give me a video script angle on X" → done in 2 minutes
- Rap writing prompts: Philosophy + Rap notebook → "5 metaphor angles connecting stoic resilience to competitive Rocket League"
- Stridemon lore: "Write an origin story for a water-type creature fitting our established comic-style lore" → cited against style guide
- Video research briefs: dump 3-5 sources into temp notebook → "summarize the most interesting talking points for a video about X"

### 5. Feed Prometheus automatically
Long-game payoff. RA-H insights extracted from Open Notebook surface as Prometheus cards:
- "You explored stoicism 2 weeks ago — here''s what''s new"
- "3 new Godot devlogs match your game dev interests"
- "Connection Drop: Batman''s psychology maps to your rap writing themes"

## The Daily Loop
Chrome Extension clips content → Open Notebook notebook
→ Chat / Audio Overview on walk
→ Best insights → RA-H nodes via Claude Code
→ Prometheus surfaces them + connects across domains
→ Used in Godot, rap, YouTube, Stridemon

## Notebook-Specific Use Cases
- Rocket League: chat for strategy, audio on walks, script fuel for Nerdforce
- Game Dev: chat while building, reference during coding sessions
- Philosophy: audio overviews on walks, lyrical fuel for rap, wellness mindset
- Comics & Lore: Stridemon creature design reference, rap imagery, video cross-niche
- Rap & Writing: creative prompts, lyrical connections, technique reference
- AI & Tech: Prometheus competitive research, trend awareness, graph enrichment
- Stridemon: lore bible assistant, design consistency checker',NULL,NULL,NULL,'not_chunked');
INSERT OR IGNORE INTO nodes (id,title,description,notes,link,event_date,created_at,updated_at,metadata,chunk,embedding,embedding_updated_at,embedding_text,chunk_status) VALUES (32,'grocery-tracker — AI Recipe Engine (search.py Phase 2)','New Claude-powered functions and routes in routes/search.py \u2014 generates full recipes, extracts from webpages, produces variations, and suggests ingredient substitutions.','**File:** `C:/Projects/routes/search.py`\n\n**New helper functions:**\n\n`get_full_recipe(meal_name, servings=4)`\n- Calls claude-sonnet-4-6, returns JSON: `{ingredients, instructions, dietary_flags, tags}`\n- Ingredients: names only (no quantities)\n- Instructions: numbered steps\n- dietary_flags: from [vegetarian, vegan, gluten-free, dairy-free, nut-free, low-carb]\n\n`get_full_recipe_from_text(page_text)`\n- Same structure but extracts from raw webpage text (first 6000 chars)\n- Also returns `servings` integer\n- Returns `{ingredients: []}` if no recipe found\n\n`get_recipe_variations(meal_name, variation_type)`\n- variation_type: ''vegetarian'' | ''cheaper'' | ''quick''\n- Returns: `{name, ingredients, instructions, notes}` (notes = explanation of changes)\n\n`get_ingredient_substitution(ingredient, meal_name)`\n- Returns JSON array: `[{name, note}, ...]` \u2014 3 substitutes with brief why/how notes\n\n**New routes:**\n- `POST /generate-full` \u2014 body: `{meal_name, servings}` \u2192 full recipe JSON\n- `POST /api/recipe/variations` \u2014 body: `{meal_name, type}` \u2192 variation JSON\n- `POST /api/recipe/substitutions` \u2014 body: `{ingredient, meal_name}` \u2192 `{ingredient, substitutions: [...]}`\n\n**Model used:** claude-sonnet-4-6 (upgraded from claude-sonnet-4-20250514 for new functions)\n**JSON parsing:** strips ```json fences before json.loads()',NULL,NULL,'2026-03-17T01:48:29.988Z','2026-03-17T01:48:29.988Z','{}','grocery-tracker — AI Recipe Engine (search.py Phase 2)

New Claude-powered functions and routes in routes/search.py \u2014 generates full recipes, extracts from webpages, produces variations, and suggests ingredient substitutions.

**File:** `C:/Projects/routes/search.py`\n\n**New helper functions:**\n\n`get_full_recipe(meal_name, servings=4)`\n- Calls claude-sonnet-4-6, returns JSON: `{ingredients, instructions, dietary_flags, tags}`\n- Ingredients: names only (no quantities)\n- Instructions: numbered steps\n- dietary_flags: from [vegetarian, vegan, gluten-free, dairy-free, nut-free, low-carb]\n\n`get_full_recipe_from_text(page_text)`\n- Same structure but extracts from raw webpage text (first 6000 chars)\n- Also returns `servings` integer\n- Returns `{ingredients: []}` if no recipe found\n\n`get_recipe_variations(meal_name, variation_type)`\n- variation_type: ''vegetarian'' | ''cheaper'' | ''quick''\n- Returns: `{name, ingredients, instructions, notes}` (notes = explanation of changes)\n\n`get_ingredient_substitution(ingredient, meal_name)`\n- Returns JSON array: `[{name, note}, ...]` \u2014 3 substitutes with brief why/how notes\n\n**New routes:**\n- `POST /generate-full` \u2014 body: `{meal_name, servings}` \u2192 full recipe JSON\n- `POST /api/recipe/variations` \u2014 body: `{meal_name, type}` \u2192 variation JSON\n- `POST /api/recipe/substitutions` \u2014 body: `{ingredient, meal_name}` \u2192 `{ingredient, substitutions: [...]}`\n\n**Model used:** claude-sonnet-4-6 (upgraded from claude-sonnet-4-20250514 for new functions)\n**JSON parsing:** strips ```json fences before json.loads()',NULL,NULL,NULL,'not_chunked');
INSERT OR IGNORE INTO nodes (id,title,description,notes,link,event_date,created_at,updated_at,metadata,chunk,embedding,embedding_updated_at,embedding_text,chunk_status) VALUES (33,'grocery-tracker — recipes.py Phase 2 Routes','New and updated routes in routes/recipes.py \u2014 full recipe extraction from webpages, AI recipe saving, star rating system, and tag management.','**File:** `C:/Projects/routes/recipes.py`\n\n**New routes added:**\n\n`POST /extract-recipe-full`\n- Body: `{text, url, title}` (webpage text from Chrome extension)\n- Calls `get_full_recipe_from_text()` \u2014 extracts ingredients, instructions, dietary_flags, tags, servings\n- Saves with `source=''extension''`\n- Returns: `{success, recipe_name, recipe_id, ingredient_count, has_instructions}`\n\n`POST /api/recipes/save-ai`\n- Body: `{meal_name, ingredients, instructions, dietary_flags, tags, servings}`\n- Saves AI-generated recipe with `source=''ai''`\n- Returns: `{success, recipe_id}`\n\n`POST /api/recipes/<recipe_id>/rate`\n- Body: `{rating, notes}` \u2014 rating is 1-5 int\n- Calls `db_rate_recipe()`, returns `{success}`\n\n`POST /api/recipes/<recipe_id>/tags`\n- Body: `{tags: [\"tag1\", \"tag2\"]}` \u2014 replaces tags\n- Calls `db_update_recipe_tags()`, returns `{success}`\n\n**Route ordering note:** `/api/recipes/save-ai` (static) is defined after `/<recipe_id>/save` (parameterized) \u2014 Flask resolves static routes first so no conflict.\n\n**Imports added:** `db_rate_recipe`, `db_update_recipe_tags`, `get_full_recipe_from_text`',NULL,NULL,'2026-03-17T01:48:39.428Z','2026-03-17T01:48:39.428Z','{}','grocery-tracker — recipes.py Phase 2 Routes

New and updated routes in routes/recipes.py \u2014 full recipe extraction from webpages, AI recipe saving, star rating system, and tag management.

**File:** `C:/Projects/routes/recipes.py`\n\n**New routes added:**\n\n`POST /extract-recipe-full`\n- Body: `{text, url, title}` (webpage text from Chrome extension)\n- Calls `get_full_recipe_from_text()` \u2014 extracts ingredients, instructions, dietary_flags, tags, servings\n- Saves with `source=''extension''`\n- Returns: `{success, recipe_name, recipe_id, ingredient_count, has_instructions}`\n\n`POST /api/recipes/save-ai`\n- Body: `{meal_name, ingredients, instructions, dietary_flags, tags, servings}`\n- Saves AI-generated recipe with `source=''ai''`\n- Returns: `{success, recipe_id}`\n\n`POST /api/recipes/<recipe_id>/rate`\n- Body: `{rating, notes}` \u2014 rating is 1-5 int\n- Calls `db_rate_recipe()`, returns `{success}`\n\n`POST /api/recipes/<recipe_id>/tags`\n- Body: `{tags: [\"tag1\", \"tag2\"]}` \u2014 replaces tags\n- Calls `db_update_recipe_tags()`, returns `{success}`\n\n**Route ordering note:** `/api/recipes/save-ai` (static) is defined after `/<recipe_id>/save` (parameterized) \u2014 Flask resolves static routes first so no conflict.\n\n**Imports added:** `db_rate_recipe`, `db_update_recipe_tags`, `get_full_recipe_from_text`',NULL,NULL,NULL,'not_chunked');
INSERT OR IGNORE INTO nodes (id,title,description,notes,link,event_date,created_at,updated_at,metadata,chunk,embedding,embedding_updated_at,embedding_text,chunk_status) VALUES (34,'grocery-tracker — index.html Phase 2 (Recipe Panel + Variations)','Major frontend upgrade to the Price Finder page \u2014 servings input, full AI recipe panel with instructions and dietary flags, variation modal, and Claude AI substitution suggestions in the swap modal.','**File:** `C:/Projects/templates/index.html`\n\n**Changes:**\n\n1. **Servings input** \u2014 `<input type=\"number\" id=\"servingsInput\" value=\"4\">` next to meal name field. Passed to `/generate-full`.\n\n2. **generateIngredients() updated** \u2014 now calls `POST /generate-full` instead of `/generate`. Stores result in `currentRecipeData`. Shows recipe panel.\n\n3. **Recipe panel** (`#recipePanel`, hidden until generation):\n   - Title + meta (serves N \u00b7 X ingredients)\n   - Dietary flag badges (teal, from dietary_flags array)\n   - Tag chips (amber)\n   - Numbered instruction steps with circular step numbers\n   - Save Recipe button \u2192 calls `POST /api/recipes/save-ai`\n   - Variation buttons: \ud83e\udd57 Vegetarian / \ud83d\udcb0 Budget / \u26a1 Under 30 Min\n\n4. **Variation modal** (`#variationOverlay`) \u2014 shows variation name, notes, ingredients chips, step-by-step instructions. Triggered by variation buttons via `POST /api/recipe/variations`.\n\n5. **Swap modal updated** \u2014 two sections: \"Kroger Products\" (existing) + \"AI Suggestions\" (new). AI suggestions loaded via `fetchAiSubs()` \u2192 `POST /api/recipe/substitutions`. Both sections load in parallel when swap opens.\n\n**New JS functions:** `showRecipePanel(data)`, `saveToRecipes()`, `getVariation(type)`, `closeVariation()`, `fetchAiSubs(ingredient, mealName)`\n**New state:** `let currentRecipeData = null;`',NULL,NULL,'2026-03-17T01:48:56.474Z','2026-03-17T01:48:56.474Z','{}','grocery-tracker — index.html Phase 2 (Recipe Panel + Variations)

Major frontend upgrade to the Price Finder page \u2014 servings input, full AI recipe panel with instructions and dietary flags, variation modal, and Claude AI substitution suggestions in the swap modal.

**File:** `C:/Projects/templates/index.html`\n\n**Changes:**\n\n1. **Servings input** \u2014 `<input type=\"number\" id=\"servingsInput\" value=\"4\">` next to meal name field. Passed to `/generate-full`.\n\n2. **generateIngredients() updated** \u2014 now calls `POST /generate-full` instead of `/generate`. Stores result in `currentRecipeData`. Shows recipe panel.\n\n3. **Recipe panel** (`#recipePanel`, hidden until generation):\n   - Title + meta (serves N \u00b7 X ingredients)\n   - Dietary flag badges (teal, from dietary_flags array)\n   - Tag chips (amber)\n   - Numbered instruction steps with circular step numbers\n   - Save Recipe button \u2192 calls `POST /api/recipes/save-ai`\n   - Variation buttons: \ud83e\udd57 Vegetarian / \ud83d\udcb0 Budget / \u26a1 Under 30 Min\n\n4. **Variation modal** (`#variationOverlay`) \u2014 shows variation name, notes, ingredients chips, step-by-step instructions. Triggered by variation buttons via `POST /api/recipe/variations`.\n\n5. **Swap modal updated** \u2014 two sections: \"Kroger Products\" (existing) + \"AI Suggestions\" (new). AI suggestions loaded via `fetchAiSubs()` \u2192 `POST /api/recipe/substitutions`. Both sections load in parallel when swap opens.\n\n**New JS functions:** `showRecipePanel(data)`, `saveToRecipes()`, `getVariation(type)`, `closeVariation()`, `fetchAiSubs(ingredient, mealName)`\n**New state:** `let currentRecipeData = null;`',NULL,NULL,NULL,'not_chunked');
INSERT OR IGNORE INTO nodes (id,title,description,notes,link,event_date,created_at,updated_at,metadata,chunk,embedding,embedding_updated_at,embedding_text,chunk_status) VALUES (35,'grocery-tracker — recipes.html Phase 2 (Ratings, Filters, Instructions)','Major UI upgrade to the My Recipes page \u2014 star ratings with notes, dietary flag badges, source badges, collapsible instructions, tag chips, filter bar, and direct budget plan integration.','**File:** `C:/Projects/templates/recipes.html`\n\n**New card features:**\n- **Source badge** \u2014 \"AI\" (purple) or \"Web\" (green) based on recipe.source field\n- **Star rating row** \u2014 5 filled/empty stars from recipe.rating (0-5)\n- **Dietary flag badges** \u2014 teal chips from recipe.dietary_flags array\n- **Tag chips** \u2014 amber, from recipe.tags array, shown below ingredient section\n- **Notes preview** \u2014 italic quote if recipe.notes is set\n- **Collapsible instructions** \u2014 \"Instructions\" button toggles step panel; steps have numbered circles\n- **Serves X** \u2014 shown in ingredient count label\n- **Rate button (★)** in card header \u2192 opens rate dialog\n- **\ud83d\udcc5 button** \u2192 opens day picker to add to budget plan\n\n**New UI elements:**\n- **Filter bar** \u2014 chip buttons: All / AI Generated / From Web / Rated / Vegetarian / Vegan / Gluten-Free. Active filter + text search combine.\n- **Rate dialog** \u2014 5 clickable stars + notes textarea \u2192 `POST /api/recipes/<id>/rate`. Updates allRecipes in memory, re-renders.\n- **Budget day picker dialog** \u2014 7 day buttons \u2192 `POST /api/budget/meal/from-recipe/<id>` with `{day}`. Prices recipe against Kroger and adds to active budget plan.\n\n**New JS:** `setFilter()`, `openRate()`, `closeRate()`, `setRating()`, `updateRateStars()`, `submitRating()`, `openBudgetPicker()`, `closeBudget()`, `addToBudget()`, `toggleInstructions()`\n**New state:** `activeFilter = ''all''`, `pendingRateId`, `pendingRating`, `pendingBudgetId`',NULL,NULL,'2026-03-17T01:49:10.837Z','2026-03-17T01:49:10.837Z','{}','grocery-tracker — recipes.html Phase 2 (Ratings, Filters, Instructions)

Major UI upgrade to the My Recipes page \u2014 star ratings with notes, dietary flag badges, source badges, collapsible instructions, tag chips, filter bar, and direct budget plan integration.

**File:** `C:/Projects/templates/recipes.html`\n\n**New card features:**\n- **Source badge** \u2014 \"AI\" (purple) or \"Web\" (green) based on recipe.source field\n- **Star rating row** \u2014 5 filled/empty stars from recipe.rating (0-5)\n- **Dietary flag badges** \u2014 teal chips from recipe.dietary_flags array\n- **Tag chips** \u2014 amber, from recipe.tags array, shown below ingredient section\n- **Notes preview** \u2014 italic quote if recipe.notes is set\n- **Collapsible instructions** \u2014 \"Instructions\" button toggles step panel; steps have numbered circles\n- **Serves X** \u2014 shown in ingredient count label\n- **Rate button (★)** in card header \u2192 opens rate dialog\n- **\ud83d\udcc5 button** \u2192 opens day picker to add to budget plan\n\n**New UI elements:**\n- **Filter bar** \u2014 chip buttons: All / AI Generated / From Web / Rated / Vegetarian / Vegan / Gluten-Free. Active filter + text search combine.\n- **Rate dialog** \u2014 5 clickable stars + notes textarea \u2192 `POST /api/recipes/<id>/rate`. Updates allRecipes in memory, re-renders.\n- **Budget day picker dialog** \u2014 7 day buttons \u2192 `POST /api/budget/meal/from-recipe/<id>` with `{day}`. Prices recipe against Kroger and adds to active budget plan.\n\n**New JS:** `setFilter()`, `openRate()`, `closeRate()`, `setRating()`, `updateRateStars()`, `submitRating()`, `openBudgetPicker()`, `closeBudget()`, `addToBudget()`, `toggleInstructions()`\n**New state:** `activeFilter = ''all''`, `pendingRateId`, `pendingRating`, `pendingBudgetId`',NULL,NULL,NULL,'not_chunked');
INSERT OR IGNORE INTO nodes (id,title,description,notes,link,event_date,created_at,updated_at,metadata,chunk,embedding,embedding_updated_at,embedding_text,chunk_status) VALUES (36,'grocery-tracker — budget.py: Add Meal from Saved Recipe','New route in budget.py that looks up a saved recipe by ID, prices all non-pantry ingredients via Kroger, and adds the meal to the active weekly budget plan for a chosen day.','**File:** `C:/Projects/routes/budget.py`\n\n**New route:** `POST /api/budget/meal/from-recipe/<recipe_id>`\n- Body: `{day}` \u2014 day of week string (Monday\u2013Sunday)\n- Loads recipe from `db_load_recipes()`, 404 if not found\n- Filters ingredients against pantry via `is_in_pantry()`\n- Prices remaining ingredients in parallel via `ThreadPoolExecutor` \u2192 `find_cheapest()`\n- Calls `db_record_prices()`, `db_get_active_plan()`, `db_add_budget_meal()`\n- Returns: `{success, total, budget}` (full refreshed plan)\n\n**New import added:** `db_load_recipes` from database\n\n**Pattern:** same pricing flow as `add_budget_meal()` but sourced from saved recipe instead of user-supplied ingredient list. Eliminates need to manually re-enter ingredients when adding a saved recipe to the budget planner.',NULL,NULL,'2026-03-17T01:49:20.088Z','2026-03-17T01:49:20.088Z','{}','grocery-tracker — budget.py: Add Meal from Saved Recipe

New route in budget.py that looks up a saved recipe by ID, prices all non-pantry ingredients via Kroger, and adds the meal to the active weekly budget plan for a chosen day.

**File:** `C:/Projects/routes/budget.py`\n\n**New route:** `POST /api/budget/meal/from-recipe/<recipe_id>`\n- Body: `{day}` \u2014 day of week string (Monday\u2013Sunday)\n- Loads recipe from `db_load_recipes()`, 404 if not found\n- Filters ingredients against pantry via `is_in_pantry()`\n- Prices remaining ingredients in parallel via `ThreadPoolExecutor` \u2192 `find_cheapest()`\n- Calls `db_record_prices()`, `db_get_active_plan()`, `db_add_budget_meal()`\n- Returns: `{success, total, budget}` (full refreshed plan)\n\n**New import added:** `db_load_recipes` from database\n\n**Pattern:** same pricing flow as `add_budget_meal()` but sourced from saved recipe instead of user-supplied ingredient list. Eliminates need to manually re-enter ingredients when adding a saved recipe to the budget planner.',NULL,NULL,NULL,'not_chunked');
INSERT OR IGNORE INTO nodes (id,title,description,notes,link,event_date,created_at,updated_at,metadata,chunk,embedding,embedding_updated_at,embedding_text,chunk_status) VALUES (37,'grocery-tracker — My Recipes → Price Finder Recipe Panel Flow','End-to-end feature connecting My Recipes to Price Finder — passes recipe_id in URL params so the full recipe panel and ↺ Update Recipe button are fully functional after navigating from a saved recipe.','## What was built

When clicking "Find Prices →" from the My Recipes tab, `recipe_id` is now included in the URL params alongside `meal` and `ingredients`.

On the Price Finder page (`index.html`), the `window.load` handler detects `recipe_id`, fetches the full recipe from `/api/recipes`, populates `currentRecipeData`, and calls `showRecipePanel()` — making the recipe panel appear exactly as if the user had just generated the recipe fresh.

This means the ↺ Update Recipe button (which calls `POST /refine-recipe` via Claude) works fully in the My Recipes → Price Finder flow, not just when generating a new recipe.

## Files changed
- `templates/recipes.html` — `findPrices()` adds `recipe_id` to URL params
- `templates/index.html` — `window.load` handler fetches recipe by ID and restores panel state

## Commit
`8593ae3` — "Pass recipe_id through Price Finder flow for full recipe panel"',NULL,NULL,'2026-03-17T02:13:56.258Z','2026-03-17T02:13:56.258Z','{}','grocery-tracker — My Recipes → Price Finder Recipe Panel Flow

End-to-end feature connecting My Recipes to Price Finder — passes recipe_id in URL params so the full recipe panel and ↺ Update Recipe button are fully functional after navigating from a saved recipe.

## What was built

When clicking "Find Prices →" from the My Recipes tab, `recipe_id` is now included in the URL params alongside `meal` and `ingredients`.

On the Price Finder page (`index.html`), the `window.load` handler detects `recipe_id`, fetches the full recipe from `/api/recipes`, populates `currentRecipeData`, and calls `showRecipePanel()` — making the recipe panel appear exactly as if the user had just generated the recipe fresh.

This means the ↺ Update Recipe button (which calls `POST /refine-recipe` via Claude) works fully in the My Recipes → Price Finder flow, not just when generating a new recipe.

## Files changed
- `templates/recipes.html` — `findPrices()` adds `recipe_id` to URL params
- `templates/index.html` — `window.load` handler fetches recipe by ID and restores panel state

## Commit
`8593ae3` — "Pass recipe_id through Price Finder flow for full recipe panel"',NULL,NULL,NULL,'not_chunked');
INSERT OR IGNORE INTO nodes (id,title,description,notes,link,event_date,created_at,updated_at,metadata,chunk,embedding,embedding_updated_at,embedding_text,chunk_status) VALUES (38,'Grocery Tracker — Aldi & Lidl Integration via Apify (Deferred)','Deferred implementation plan for adding Aldi and Lidl price comparison to the grocery tracker app using Apify scraper actors — shelved until greater financial stability, as Apify has per-result costs (~$0.005/result).','## Status: DEFERRED — revisit when financially stable

## Why deferred
Apify charges ~$0.005/result. Searching 10 ingredients across both stores = ~$0.10 per search. Small individually but adds up with regular use. Free tier is very limited (10 trial results). Prioritize when budget allows.

## Apify Actors to use
- Aldi: eneiromatos/ultimate-aldi-scraper
  - Input: { keywords: [ingredient], maxResults: 5, minPrice: 0, maxPrice: 0 }
  - Endpoint: POST https://api.apify.com/v2/acts/eneiromatos~ultimate-aldi-scraper/run-sync-get-dataset-items?token=TOKEN
  - Output: title/name, price.amount, media.mainImageUrl, UPC
- Lidl: thenetaji/lidl-scraper
  - Input: { search: ingredient, maxItems: 5 }
  - Endpoint: POST https://api.apify.com/v2/acts/thenetaji~lidl-scraper/run-sync-get-dataset-items?token=TOKEN
  - Output: name, price, image

## Implementation Plan

### New file: routes/apify_stores.py
- search_aldi(ingredient) → normalized dict { ingredient, product_name, price, image, store="aldi" }
- search_lidl(ingredient) → normalized dict { ingredient, product_name, price, image, store="lidl" }
- search_all_stores(ingredients) → parallel ThreadPoolExecutor across both stores for all ingredients
- timeout=60 on all requests, graceful None return on failure

### Database change: database.py migration v3
ALTER TABLE price_history ADD COLUMN store TEXT DEFAULT ''kroger''
Allows price_history to track which store each price came from.

### New route: /search-all-stores in routes/search.py
1. Claude extracts ingredients from meal name (existing get_ingredients_from_meal)
2. Parallel: Kroger (existing) + search_all_stores (new Apify)
3. Returns comparison dict: { ingredient: { kroger: {...}, aldi: {...}, lidl: {...} } }

### Frontend additions
- "Compare All Stores" button on search page
- Price comparison table: ingredient | Kroger | Aldi | Lidl | Best Price (✅ highlighted)
- Total per store row at bottom
- Claude summary: "Aldi saves you $X on this meal"

### Env vars needed
APIFY_TOKEN — get from apify.com → Integrations → API Token

## Caveats
- Apify sync endpoint can be slow (30–90s per run) — add loading state
- Aldi scraper targets aldi.us, may differ from local shelf prices
- Lidl scrapers primarily target Lidl.de — US Lidl may need startUrls approach
- Treat as directionally accurate, not exact shelf price

## Claude Code prompt (ready to use when time comes)
"My grocery tracker Flask app searches Kroger via API (routes/search.py with ThreadPoolExecutor). Add Aldi and Lidl price comparison using Apify API. Create routes/apify_stores.py with search_aldi(), search_lidl(), search_all_stores() functions. Add APIFY_TOKEN env var. Add store column migration v3 to database.py. Add /search-all-stores route that calls Claude for ingredients then runs Kroger + Apify in parallel and returns price comparison dict. timeout=60, handle errors gracefully with None returns."',NULL,NULL,'2026-03-17T02:20:09.605Z','2026-03-17T02:20:09.605Z','{}','Grocery Tracker — Aldi & Lidl Integration via Apify (Deferred)

Deferred implementation plan for adding Aldi and Lidl price comparison to the grocery tracker app using Apify scraper actors — shelved until greater financial stability, as Apify has per-result costs (~$0.005/result).

## Status: DEFERRED — revisit when financially stable

## Why deferred
Apify charges ~$0.005/result. Searching 10 ingredients across both stores = ~$0.10 per search. Small individually but adds up with regular use. Free tier is very limited (10 trial results). Prioritize when budget allows.

## Apify Actors to use
- Aldi: eneiromatos/ultimate-aldi-scraper
  - Input: { keywords: [ingredient], maxResults: 5, minPrice: 0, maxPrice: 0 }
  - Endpoint: POST https://api.apify.com/v2/acts/eneiromatos~ultimate-aldi-scraper/run-sync-get-dataset-items?token=TOKEN
  - Output: title/name, price.amount, media.mainImageUrl, UPC
- Lidl: thenetaji/lidl-scraper
  - Input: { search: ingredient, maxItems: 5 }
  - Endpoint: POST https://api.apify.com/v2/acts/thenetaji~lidl-scraper/run-sync-get-dataset-items?token=TOKEN
  - Output: name, price, image

## Implementation Plan

### New file: routes/apify_stores.py
- search_aldi(ingredient) → normalized dict { ingredient, product_name, price, image, store="aldi" }
- search_lidl(ingredient) → normalized dict { ingredient, product_name, price, image, store="lidl" }
- search_all_stores(ingredients) → parallel ThreadPoolExecutor across both stores for all ingredients
- timeout=60 on all requests, graceful None return on failure

### Database change: database.py migration v3
ALTER TABLE price_history ADD COLUMN store TEXT DEFAULT ''kroger''
Allows price_history to track which store each price came from.

### New route: /search-all-stores in routes/search.py
1. Claude extracts ingredients from meal name (existing get_ingredients_from_meal)
2. Parallel: Kroger (existing) + search_all_stores (new Apify)
3. Returns comparison dict: { ingredient: { kroger: {...}, aldi: {...}, lidl: {...} } }

### Frontend additions
- "Compare All Stores" button on search page
- Price comparison table: ingredient | Kroger | Aldi | Lidl | Best Price (✅ highlighted)
- Total per store row at bottom
- Claude summary: "Aldi saves you $X on this meal"

### Env vars needed
APIFY_TOKEN — get from apify.com → Integrations → API Token

## Caveats
- Apify sync endpoint can be slow (30–90s per run) — add loading state
- Aldi scraper targets aldi.us, may differ from local shelf prices
- Lidl scrapers primarily target Lidl.de — US Lidl may need startUrls approach
- Treat as directionally accurate, not exact shelf price

## Claude Code prompt (ready to use when time comes)
"My grocery tracker Flask app searches Kroger via API (routes/search.py with ThreadPoolExecutor). Add Aldi and Lidl price comparison using Apify API. Create routes/apify_stores.py with search_aldi(), search_lidl(), search_all_stores() functions. Add APIFY_TOKEN env var. Add store column migration v3 to database.py. Add /search-all-stores route that calls Claude for ingredients then runs Kroger + Apify in parallel and returns price comparison dict. timeout=60, handle errors gracefully with None returns."',NULL,NULL,NULL,'not_chunked');
INSERT OR IGNORE INTO nodes (id,title,description,notes,link,event_date,created_at,updated_at,metadata,chunk,embedding,embedding_updated_at,embedding_text,chunk_status) VALUES (39,'Financial Freedom App Brainstorm','Brainstorm of 7 productivity, budgeting, and financial freedom app ideas ranked by build complexity — grounded in Braddon''s current stack (Flask, SQLite, Claude API) and personal financial situation.','## Ranked by Build Complexity

### NOW (free/single page, immediate personal value)
1. Debt Snowball/Avalanche Planner — single page tool, no backend needed
2. Financial Freedom Number Calculator — interactive FI number + path calculator

### SOON (extends grocery tracker Flask app)
3. Huge Papa Budget OS — full life budget dashboard extending grocery tracker
4. Side Hustle Tracker — income tracker for irregular/multiple streams

### LATER (more complex integrations)
5. Subscription Killer — CSV bank import + Claude auto-detects recurring charges
6. Creator Revenue Projector — YouTube API + revenue projection for Nerdforce

### VISION
7. The Grind Ledger — unified life OS combining all above into one dashboard with Claude daily briefing. Financial equivalent of Prometheus.

## Key Philosophy
All apps share the same meta-pattern as RA-H: data = database, Claude = engine, app = interface.
The Grind Ledger is the financial Command Center — same concept as Prometheus but for money.

## Connections to existing graph
- Budget OS extends grocery-tracker (nodes 8-13)
- Creator Revenue Projector uses YouTube API from Prometheus stack (node 17)
- The Grind Ledger = financial equivalent of Huge Papa Command Center (node 19)
- All apps connect to Mental Health & Wellness (node 6) — financial stress = mental health
- Philosophy node (22) informs the stoic framing of financial freedom',NULL,NULL,'2026-03-17T02:23:54.939Z','2026-03-17T02:23:54.939Z','{}','Financial Freedom App Brainstorm

Brainstorm of 7 productivity, budgeting, and financial freedom app ideas ranked by build complexity — grounded in Braddon''s current stack (Flask, SQLite, Claude API) and personal financial situation.

## Ranked by Build Complexity

### NOW (free/single page, immediate personal value)
1. Debt Snowball/Avalanche Planner — single page tool, no backend needed
2. Financial Freedom Number Calculator — interactive FI number + path calculator

### SOON (extends grocery tracker Flask app)
3. Huge Papa Budget OS — full life budget dashboard extending grocery tracker
4. Side Hustle Tracker — income tracker for irregular/multiple streams

### LATER (more complex integrations)
5. Subscription Killer — CSV bank import + Claude auto-detects recurring charges
6. Creator Revenue Projector — YouTube API + revenue projection for Nerdforce

### VISION
7. The Grind Ledger — unified life OS combining all above into one dashboard with Claude daily briefing. Financial equivalent of Prometheus.

## Key Philosophy
All apps share the same meta-pattern as RA-H: data = database, Claude = engine, app = interface.
The Grind Ledger is the financial Command Center — same concept as Prometheus but for money.

## Connections to existing graph
- Budget OS extends grocery-tracker (nodes 8-13)
- Creator Revenue Projector uses YouTube API from Prometheus stack (node 17)
- The Grind Ledger = financial equivalent of Huge Papa Command Center (node 19)
- All apps connect to Mental Health & Wellness (node 6) — financial stress = mental health
- Philosophy node (22) informs the stoic framing of financial freedom',NULL,NULL,NULL,'not_chunked');
INSERT OR IGNORE INTO nodes (id,title,description,notes,link,event_date,created_at,updated_at,metadata,chunk,embedding,embedding_updated_at,embedding_text,chunk_status) VALUES (40,'Bank Integration — Plaid & Teller (Deferred Implementation Guide)','Deferred technical guide for linking Chase bank account to personal finance apps — covers both Plaid (industry standard) and Teller (preferred for indie devs, no waitlist, free for personal use, instant access).','## Status: DEFERRED — revisit when financially stable

## Why Plaid
- Official Chase + Plaid partnership — uses Chase''s own OAuth API, not screen scraping
- Your credentials never touch your app — Plaid handles auth via encrypted Link module
- Chase supports App-to-App OAuth (Touch ID / Face ID via Chase mobile app)
- Powers Venmo, YNAB, Robinhood, Copilot, and thousands of other finance apps
- Supports 12,000+ financial institutions via one API

## Cost for Personal Use
- Sandbox: completely free, unlimited API calls (fake test data)
- Production: first 200 API calls free
- Personal use (just you, one account, one connection) = effectively zero cost
- Only pay at scale when serving many users

## What You Get (Read-Only Access)
- Transaction history — every purchase, auto-categorized
- Account balances — checking, savings, credit cards
- Income detection — recurring deposits identified automatically
- Liabilities — credit card debt, loans

## Setup Steps
1. Sign up at dashboard.plaid.com → get PLAID_CLIENT_ID and PLAID_SECRET
2. pip install plaid-python
3. Add env vars: PLAID_CLIENT_ID, PLAID_SECRET, PLAID_ENV=sandbox
4. Implement two Flask routes (see below)
5. Apply for Production access (brief review, few days for personal use apps)

## The Two Core Flask Routes

### Route 1: Create Link Token (initializes Plaid Link UI widget)
POST /plaid/create-link-token
- Creates a short-lived token for the frontend to open Plaid''s secure login UI
- Specify products=["transactions"] and country_codes=["US"]

### Route 2: Exchange Public Token
POST /plaid/exchange-token
- Receives public_token from frontend after user connects Chase
- Exchanges for permanent access_token via Plaid API
- ENCRYPT access_token before storing in SQLite

## Auth Flow
Frontend loads Plaid Link widget
→ User clicks Connect Chase
→ Chase OAuth redirect → user approves in Chase app (Touch ID / Face ID)
→ Plaid returns public_token to frontend
→ Frontend sends to Flask backend
→ Flask exchanges for permanent access_token
→ Store encrypted in SQLite
→ Use access_token to call /transactions/sync whenever needed

## Security Rules (Non-Negotiable)
1. Never store raw bank credentials — only the Plaid access_token (meaningless string)
2. Encrypt access_token at rest using Python cryptography library + env var key
3. Keep app local or private-only — don''t deploy publicly until Plaid production review approved
4. Going public requires Plaid production approval (explain personal use = few days turnaround)

## Claude Integration Layer
Once transactions sync to SQLite, Claude reads them and produces:
- Spending breakdown by category
- Subscription detection (recurring same-amount charges)
- Budget vs. actual comparison
- Debt snowball progress tracking
- Weekly financial health summary

## Connects To
- Huge Papa Budget OS (node 39) — primary integration target
- Debt Snowball Planner — tracks real payments automatically
- Subscription Killer — detects recurring charges automatically
- The Grind Ledger (vision) — live bank data as foundation

## Claude Code Prompt (ready for when time comes)
"Add Plaid bank integration to my Flask app. Install plaid-python. Add two routes: POST /plaid/create-link-token (creates Plaid Link token with transactions product for US) and POST /plaid/exchange-token (exchanges public_token for access_token, encrypts it with Python cryptography Fernet using ENCRYPTION_KEY env var, stores in SQLite). Add POST /plaid/sync-transactions that decrypts token, calls transactions_sync, saves results to a transactions table with date/name/amount/category fields. Use PLAID_CLIENT_ID, PLAID_SECRET, PLAID_ENV env vars. Start in sandbox mode."



## PREFERRED ALTERNATIVE: Teller (teller.io)

### Why Teller over Plaid for personal use
- NO waitlist, NO approval process — sign up and get app ID instantly
- FREE for independent developers and prototyping, no per-call fees at personal scale
- Connects to 7,000+ financial institutions including Chase (instant, no microdeposit wait)
- Integrates in an afternoon — simpler API than Plaid, excellent docs
- Uses real bank APIs (not screen scraping) — faster, more reliable, live data

### Security model (more secure than Plaid)
- Client certificate system: Teller issues a certificate from dashboard
- Access tokens are USELESS without the matching private key certificate
- Even if token is stolen, attacker can''t use it without your cert
- Sensitive data goes directly to Teller servers, bypasses your app entirely

### Teller Setup (same-day, no waiting)
1. Sign up at teller.io → get application_id instantly from dashboard
2. Generate client certificate from dashboard
3. Add to frontend: <script src=''https://cdn.teller.io/connect/connect.js''>
4. User clicks Connect → Teller Connect UI → logs into Chase
5. onSuccess callback returns accessToken
6. Use accessToken + certificate → GET https://api.teller.io/accounts
7. GET https://api.teller.io/accounts/{id}/transactions

### Core Flask integration pattern
- Frontend: include Teller Connect JS, setup with applicationId + products
- Backend: receive accessToken from frontend, store encrypted in SQLite
- Fetch transactions via requests library using HTTP Basic Auth (token as username)
- curl equivalent: curl -u ACCESS_TOKEN: https://api.teller.io/accounts

### Sandbox testing
- Username: ''username'', Password: ''password'' in Teller Connect
- Instant sandbox access, no real bank needed for development
- Switch ENV from sandbox → development → production when ready

### When to use Plaid instead
- If you eventually go public and need brand recognition (Plaid is more trusted by users)
- If you need income verification, identity, or liabilities products
- If you need >12,000 institution coverage (Plaid covers more)
- Plaid production requires approval review (few days for personal apps)',NULL,NULL,'2026-03-17T02:27:53.007Z','2026-03-17T02:30:44.586Z','{}','Plaid + Chase Bank Integration — Deferred Implementation Guide

Deferred technical guide for linking Chase bank account to personal finance apps via Plaid API — shelved until financially stable, covers OAuth flow, Flask routes, security practices, and cost breakdown for personal use.

## Status: DEFERRED — revisit when financially stable

## Why Plaid
- Official Chase + Plaid partnership — uses Chase''s own OAuth API, not screen scraping
- Your credentials never touch your app — Plaid handles auth via encrypted Link module
- Chase supports App-to-App OAuth (Touch ID / Face ID via Chase mobile app)
- Powers Venmo, YNAB, Robinhood, Copilot, and thousands of other finance apps
- Supports 12,000+ financial institutions via one API

## Cost for Personal Use
- Sandbox: completely free, unlimited API calls (fake test data)
- Production: first 200 API calls free
- Personal use (just you, one account, one connection) = effectively zero cost
- Only pay at scale when serving many users

## What You Get (Read-Only Access)
- Transaction history — every purchase, auto-categorized
- Account balances — checking, savings, credit cards
- Income detection — recurring deposits identified automatically
- Liabilities — credit card debt, loans

## Setup Steps
1. Sign up at dashboard.plaid.com → get PLAID_CLIENT_ID and PLAID_SECRET
2. pip install plaid-python
3. Add env vars: PLAID_CLIENT_ID, PLAID_SECRET, PLAID_ENV=sandbox
4. Implement two Flask routes (see below)
5. Apply for Production access (brief review, few days for personal use apps)

## The Two Core Flask Routes

### Route 1: Create Link Token (initializes Plaid Link UI widget)
POST /plaid/create-link-token
- Creates a short-lived token for the frontend to open Plaid''s secure login UI
- Specify products=["transactions"] and country_codes=["US"]

### Route 2: Exchange Public Token
POST /plaid/exchange-token
- Receives public_token from frontend after user connects Chase
- Exchanges for permanent access_token via Plaid API
- ENCRYPT access_token before storing in SQLite

## Auth Flow
Frontend loads Plaid Link widget
→ User clicks Connect Chase
→ Chase OAuth redirect → user approves in Chase app (Touch ID / Face ID)
→ Plaid returns public_token to frontend
→ Frontend sends to Flask backend
→ Flask exchanges for permanent access_token
→ Store encrypted in SQLite
→ Use access_token to call /transactions/sync whenever needed

## Security Rules (Non-Negotiable)
1. Never store raw bank credentials — only the Plaid access_token (meaningless string)
2. Encrypt access_token at rest using Python cryptography library + env var key
3. Keep app local or private-only — don''t deploy publicly until Plaid production review approved
4. Going public requires Plaid production approval (explain personal use = few days turnaround)

## Claude Integration Layer
Once transactions sync to SQLite, Claude reads them and produces:
- Spending breakdown by category
- Subscription detection (recurring same-amount charges)
- Budget vs. actual comparison
- Debt snowball progress tracking
- Weekly financial health summary

## Connects To
- Huge Papa Budget OS (node 39) — primary integration target
- Debt Snowball Planner — tracks real payments automatically
- Subscription Killer — detects recurring charges automatically
- The Grind Ledger (vision) — live bank data as foundation

## Claude Code Prompt (ready for when time comes)
"Add Plaid bank integration to my Flask app. Install plaid-python. Add two routes: POST /plaid/create-link-token (creates Plaid Link token with transactions product for US) and POST /plaid/exchange-token (exchanges public_token for access_token, encrypts it with Python cryptography Fernet using ENCRYPTION_KEY env var, stores in SQLite). Add POST /plaid/sync-transactions that decrypts token, calls transactions_sync, saves results to a transactions table with date/name/amount/category fields. Use PLAID_CLIENT_ID, PLAID_SECRET, PLAID_ENV env vars. Start in sandbox mode."',NULL,NULL,NULL,'not_chunked');
INSERT OR IGNORE INTO nodes (id,title,description,notes,link,event_date,created_at,updated_at,metadata,chunk,embedding,embedding_updated_at,embedding_text,chunk_status) VALUES (41,'Budget OS — Gig Worker / Uber Eats Mode','Complete design spec for adapting the Family Budget OS to handle chaotic gig income — Mom and Dad do Uber Eats, Braddon has app/YouTube income, others have their own streams. Covers buffer system, runway metric, income logging, tax tracking, and stoic emotional safety layer.','## Core Problem
Standard budget apps assume salary. Gig work is chaos. The solution: insulate fixed life from variable income using a buffer system.

## The Three Buckets System
EARN → HOLD → SPEND

Buffer Account (float): covers fixed bills always
Spending Pool: day-to-day variable expenses
Emergency Jar: untouched, true emergencies only

Never budget income you don''t have yet. Only spend what''s already in the buckets.

## Dashboard — Gig Mode
Primary metric is RUNWAY (not "budget remaining"):
- Runway = days until buffer hits zero at average burn rate
- If runway > 14 days → you''re fine, close the app
- Available buffer shown with fixed bills covered through X date
- Trailing 4-week average income (weekly + monthly)
- Claude brief: pattern-based shift recommendation

## Income Logging (30 seconds per run)
Fields: Date, Hours worked, Earnings (base + tips), Miles driven, Platform
Auto-calculates:
- Effective hourly rate
- Weekly target remaining
- Best earning day of the week

## Income Patterns Panel (Claude-powered)
After 4-6 weeks of data, Claude identifies:
- Best days by average earnings and hit rate
- Best time windows (lunch vs dinner vs late night $/hr)
- Weather impact (rain = +34% orders)
- Holiday multipliers
- Personal weekly floor (minimum to cover variable expenses)

## The Gig Budget Rules (enforced by app)

### Rule 1 — Weekly Salary Smoothing
Set a fixed weekly "salary" (e.g. $250). Earn above → surplus to buffer. Earn below → draw from buffer. Smooths income chaos into consistent spending power.

### Rule 2 — Fixed Bills from Buffer Only
Rent never comes from "what I made this week." Always from buffer. Always 2-4 weeks ahead psychologically and literally.

### Rule 3 — 50/30/20 Gig Version
50% of each week → buffer (bills + float)
30% → spending (food, gas, personal)
20% → debt snowball or savings
Big week surplus → buffer first, then debt.

### Rule 4 — Monday Floor Alert
Every Monday: "Your floor this week is $178. Here''s how to hit it."
Floor = minimum weekly earnings to cover variable expenses without touching buffer.

## Tax Handling (critical — Uber Eats doesn''t withhold)
- Tracks gross earnings per run
- Tracks miles driven (deductible at ~$0.67/mile)
- Estimates tax owed (15% self-employment on net)
- Shows set-aside progress vs estimated owed
- Quarterly due date countdown
- Claude monthly reminder to set aside correct amount
- Year-end: estimated mileage deduction ($500-$2,000 typical)

## Slow Week Protocol
When a slow week is detected — no panic mode:
- Buffer runway shown prominently (reassurance)
- Specific recovery options (which shifts to push)
- Rain/surge forecast context
- "Action needed: None urgent" if runway is healthy

## Gig Income Optimizer Module
Built from personal logged data — no external API:
- Best shift windows ranked by avg $/hr and hit rate
- Weather-based demand forecast
- "To hit $300 this week, work these 3 windows = ~$320"
- Updates weekly as more runs are logged

## Emotional Safety Layer (Philosophy + Wellness connection)
Stoic reframes throughout:
- "You controlled your hours today. The surge will come or it won''t."
- One-number rule: if runway > 14 days, close the app
- Gentle pushback on excessive checking during slow stretches
- "You''ve checked 4 times today. Runway is 18 days. Go walk with Stridemon."
- App tone: honest mirror, not judge

## New DB Tables Needed
runs (id, date, hours, earnings, miles, platform, created_at)
buffer (id, date, amount, type: deposit/withdrawal, note)
weekly_salary_target (amount, updated_at)
tax_tracker (year, gross, miles, estimated_owed, set_aside)

## Integration Points
- Extends Budget OS dashboard with Gig Mode toggle
- Connects to Stridemon (walking = reset from financial stress)
- Connects to Mental Health & Wellness node (financial anxiety management)
- Teller sync (deferred): auto-import Uber Eats deposits when bank linked



## CORRECTION (March 2026)
Uber Eats gig work is Mom and Dad''s income stream — NOT Braddon''s.
Braddon''s income streams: app revenue, YouTube AdSense, freelance/other.
Other family members: Bro 1 and Bro 2 have their own separate income types (TBD).
All gig worker mode features (buffer, runway, run logging, tax tracker) apply to Mom + Dad''s Uber Eats accounts.',NULL,NULL,'2026-03-17T02:39:23.411Z','2026-03-17T02:46:51.811Z','{}','Budget OS — Gig Worker / Uber Eats Mode

Complete design spec for adapting the Huge Papa Budget OS to handle chaotic, irregular gig income (Uber Eats) — covers buffer system, runway metric, income logging, tax tracking, slow-week protocol, and stoic emotional safety layer.

## Core Problem
Standard budget apps assume salary. Gig work is chaos. The solution: insulate fixed life from variable income using a buffer system.

## The Three Buckets System
EARN → HOLD → SPEND

Buffer Account (float): covers fixed bills always
Spending Pool: day-to-day variable expenses
Emergency Jar: untouched, true emergencies only

Never budget income you don''t have yet. Only spend what''s already in the buckets.

## Dashboard — Gig Mode
Primary metric is RUNWAY (not "budget remaining"):
- Runway = days until buffer hits zero at average burn rate
- If runway > 14 days → you''re fine, close the app
- Available buffer shown with fixed bills covered through X date
- Trailing 4-week average income (weekly + monthly)
- Claude brief: pattern-based shift recommendation

## Income Logging (30 seconds per run)
Fields: Date, Hours worked, Earnings (base + tips), Miles driven, Platform
Auto-calculates:
- Effective hourly rate
- Weekly target remaining
- Best earning day of the week

## Income Patterns Panel (Claude-powered)
After 4-6 weeks of data, Claude identifies:
- Best days by average earnings and hit rate
- Best time windows (lunch vs dinner vs late night $/hr)
- Weather impact (rain = +34% orders)
- Holiday multipliers
- Personal weekly floor (minimum to cover variable expenses)

## The Gig Budget Rules (enforced by app)

### Rule 1 — Weekly Salary Smoothing
Set a fixed weekly "salary" (e.g. $250). Earn above → surplus to buffer. Earn below → draw from buffer. Smooths income chaos into consistent spending power.

### Rule 2 — Fixed Bills from Buffer Only
Rent never comes from "what I made this week." Always from buffer. Always 2-4 weeks ahead psychologically and literally.

### Rule 3 — 50/30/20 Gig Version
50% of each week → buffer (bills + float)
30% → spending (food, gas, personal)
20% → debt snowball or savings
Big week surplus → buffer first, then debt.

### Rule 4 — Monday Floor Alert
Every Monday: "Your floor this week is $178. Here''s how to hit it."
Floor = minimum weekly earnings to cover variable expenses without touching buffer.

## Tax Handling (critical — Uber Eats doesn''t withhold)
- Tracks gross earnings per run
- Tracks miles driven (deductible at ~$0.67/mile)
- Estimates tax owed (15% self-employment on net)
- Shows set-aside progress vs estimated owed
- Quarterly due date countdown
- Claude monthly reminder to set aside correct amount
- Year-end: estimated mileage deduction ($500-$2,000 typical)

## Slow Week Protocol
When a slow week is detected — no panic mode:
- Buffer runway shown prominently (reassurance)
- Specific recovery options (which shifts to push)
- Rain/surge forecast context
- "Action needed: None urgent" if runway is healthy

## Gig Income Optimizer Module
Built from personal logged data — no external API:
- Best shift windows ranked by avg $/hr and hit rate
- Weather-based demand forecast
- "To hit $300 this week, work these 3 windows = ~$320"
- Updates weekly as more runs are logged

## Emotional Safety Layer (Philosophy + Wellness connection)
Stoic reframes throughout:
- "You controlled your hours today. The surge will come or it won''t."
- One-number rule: if runway > 14 days, close the app
- Gentle pushback on excessive checking during slow stretches
- "You''ve checked 4 times today. Runway is 18 days. Go walk with Stridemon."
- App tone: honest mirror, not judge

## New DB Tables Needed
runs (id, date, hours, earnings, miles, platform, created_at)
buffer (id, date, amount, type: deposit/withdrawal, note)
weekly_salary_target (amount, updated_at)
tax_tracker (year, gross, miles, estimated_owed, set_aside)

## Integration Points
- Extends Budget OS dashboard with Gig Mode toggle
- Connects to Stridemon (walking = reset from financial stress)
- Connects to Mental Health & Wellness node (financial anxiety management)
- Teller sync (deferred): auto-import Uber Eats deposits when bank linked',NULL,NULL,NULL,'not_chunked');
INSERT OR IGNORE INTO nodes (id,title,description,notes,link,event_date,created_at,updated_at,metadata,chunk,embedding,embedding_updated_at,embedding_text,chunk_status) VALUES (42,'Family Budget OS — Full Design Spec (Multi-Income, Gig + Mixed Streams)','Full design spec for 5-member family budget OS — Braddon on SSI disability, Bro 1 on W-2 direct deposit, Mom and Dad on Uber Eats gig income, Bro 2 TBD. Covers Hub+Spoke, SSI asset limits, income modes, and tax tracking.','## FAMILY SETUP (corrected March 2026)
Mom    → Uber Eats gig income (chaotic, shift-based)
Dad    → Uber Eats gig income (chaotic, shift-based)
Braddon → App revenue + YouTube AdSense + freelance/other (irregular, project-based)
Bro 1  → TBD income type
Bro 2  → TBD income type

## Architecture: Hub + Spokes
Each person has a private SPOKE — their income, spending, debt, personal data.
The FAMILY HUB shows only what''s relevant to everyone — shared bills, contributions, runway, goals.
Nobody sees each other''s exact numbers — privacy is default, sharing is opt-in.

## Income Input Methods (ranked best to backup)

### Method A — Chase/Teller Auto-Import (DEFERRED — best when ready)
Teller reads Chase deposits. Uber Eats weekly deposits hit Thursday.
App sees "UBER EATS PAYMENT +$247.80" → auto-tags → routes to correct person''s spoke.
YouTube AdSense → Braddon''s spoke. Zero manual entry.

### Method B — Uber CSV Upload (BEST RIGHT NOW — semi-automatic)
Uber Driver app → Earnings → Statements → Download CSV (weekly)
Mom and Dad each download weekly CSV on Sundays, upload to app.
App parses: gross earnings, Uber fees, tips, net take-home, miles driven.
Takes 30 seconds. Fully accurate. Officially supported by Uber.
CSV fields: deliveries count, gross, service fee deduction, tips, net, miles.

### Method C — Weekly Uber Email Parse (semi-automatic)
Uber sends weekly earnings emails. Can IFTTT-forward to a parsing endpoint.
App extracts the total — less detail than CSV but fully automated.

### Method D — Manual Quick Log (always available, 30 seconds)
After each shift: earnings, hours, miles. Backup or mid-week check-in.
Good for seeing where you are mid-week before CSV is available.

### Method E — Apify/Uber API scraping (deferred, not recommended)
Uber Driver API exists but is limited access and complex approval.
CSV method is cleaner, officially supported, and sufficient.

## Uber Eats Payment Schedule
Weekly deposit: Thursday via direct deposit to linked bank (Chase).
Instant Pay: up to 6x per day, $0.85 fee per cash-out.
Earnings cycle: Mon 4am to Mon 3:59am next week.
Wednesday: processed. Thursday: deposited to bank.

## Family Hub Dashboard
Primary metrics:
- Household runway (days until shared bills can''t be covered)
- Contribution status per member (✅/⏳ — no amounts shown to others)
- Shared bills tracker (rent, utilities, groceries, internet)
- Emergency fund progress (family buffer built collectively)

Contribution visibility: amount shown only to contributor + admin. Others see status only.

## Contribution Models

### Option A — Flat Contribution (simplest)
Fixed monthly amounts agreed upfront. Easy to track, predictable.

### Option B — Income Percentage (fairest)
Each contributes X% of their monthly income.
High earners pay more, lower earners pay less, automatically.

### Option C — Gig Flex (Mom + Dad model)
Floor: minimum guaranteed contribution (e.g. $200)
Surplus: when earnings exceed weekly target, flag additional contribution
Slow week: pay floor only, gap covered from emergency fund, repay next good month

## Mom + Dad Gig Unit Features
Both on Uber Eats → tracked as individual spokes OR combined gig unit view.
Combined tracker shows:
- Total combined earnings per week
- Best shift combos (both online Sat dinner avg $210 combined)
- Combined mileage deduction (tracked separately per driver)
- Combined YTD tax deduction estimate

## Tax Handling (critical — Uber does NOT withhold taxes)
Per driver:
- Gross earnings tracked
- Miles driven tracked (deductible at ~$0.67/mile IRS 2025 rate)
- Net taxable income = gross - mileage deduction
- Self-employment tax estimate = ~15% of net
- Quarterly deadlines: Apr 15, Jun 15, Sep 15, Jan 15
- App shows set-aside progress vs owed, days until next quarterly due
- Year-end: typical mileage deduction $500-$2,000 per driver

## Three Bucket System (Mom + Dad income model)
EARN → HOLD → SPEND
Buffer Account: fixed bills always paid from here
Spending Pool: day-to-day variable
Emergency Jar: untouched, true emergencies only

Weekly salary smoothing: set a fixed salary (e.g. $250/week each).
Earn above → surplus to buffer. Earn below → draw from buffer.
This insulates fixed expenses from income chaos.

## Runway Metric (primary gig metric)
Runway = days until buffer hits zero at average burn rate.
Rule: if runway > 14 days → you''re fine. Close the app.
Shown prominently on dashboard. Updated with every CSV upload or manual log.

## Privacy Tiers (each person configures their own)
PRIVATE: full income, debt, personal spending, savings, FI score
CONTRIBUTION: monthly amount + paid/pending status (household sees this)
SHARED (opt-in): income range, financial goal description, gig work status

## Slow Week Protocol (gig workers)
App detects slow week → shows runway (reassurance) → specific recovery options.
"Buffer covers this. No panic." + shift suggestions based on historical patterns.
Slow week notification to household: soft alert, no amounts shown, just heads up.
Options: push hard this week / pay floor only / notify household.

## Family Goals (voted)
Any member proposes a goal. Appears on Hub when majority approves.
Examples: Emergency fund ($500), Better apartment deposit ($5,000), Bro 2 school fund.
Shows: who''s contributing, how much, estimated completion, Claude monthly allocation suggestion.

## Fairness Checker (monthly, Claude-powered)
Audits whether contribution split is fair relative to each person''s income.
Shows effective contribution rate as % of income per person.
Claude surfaces imbalances diplomatically — information, not accusation.

## Braddon''s Spoke (different from gig mode)
Income: app revenue (project-based), YouTube AdSense (monthly), freelance (variable).
Not shift-based → monthly income log rather than per-run log.
YouTube Studio CSV export → monthly earnings import.
App revenue: manual log when payments arrive.
Teller (deferred): AdSense and app payments auto-detected in Chase deposits.

## DB Tables
users (id, name, role, income_type, privacy_level, weekly_salary_target)
contributions (user_id, month, amount, status, model: flat/pct/flex)
shared_bills (name, amount, due_date, paid_by, month)
family_goals (name, target, current, contributors, votes, status)
runs (user_id, date, hours, earnings, miles, platform, shift_type)
buffer (user_id, date, amount, type: deposit/withdrawal, note)
tax_tracker (user_id, year, gross, miles, estimated_owed, set_aside)
transactions (user_id, date, name, amount, category — Teller, deferred)

## Build Order
Session 1: Multi-user auth + profile setup (income type selection)
Session 2: Family Hub (shared bills, contribution tracker, household runway)
Session 3: Individual Spokes (gig mode for Mom+Dad, standard for Braddon)
Session 4: Contribution system (flat/pct/flex, slow week protocol)
Session 5: Uber CSV parser + import flow
Session 6: Tax tracker (per driver mileage + quarterly estimates)
Session 7: Family goals + fairness checker
Session 8: Claude family digest + individual digests
Session 9 (deferred): Teller bank sync per member



## CORRECTED FAMILY INCOME PROFILES (March 2026)

Braddon   → SSI Disability (monthly fixed, strict SSI rules apply)
Bro 1     → W-2 steady job, direct deposit (predictable, bi-weekly or monthly)
Mom       → Uber Eats gig income (chaotic, shift-based)
Dad       → Uber Eats gig income (chaotic, shift-based)
Bro 2     → TBD

## BRADDON — SSI MODE

### What SSI changes about budgeting
SSI (Supplemental Security Income) has strict federal rules:
- 2025 SSI individual max: $943/month
- If you earn work income, SSI reduces after $85 exclusion: (earned - $85) / 2 reduction
- Having more than $2,000 in countable assets = INELIGIBLE for SSI
- Excluded assets: primary home, one car, personal items, ABLE account (up to $100k)
- App must NEVER encourage saving past the $2,000 countable asset limit

### SSI-Safe budgeting rules the app enforces
1. No savings goal that pushes countable assets over $1,800 (buffer below $2,000 limit)
2. Claude never suggests ''save more'' without flagging SSI asset limits first
3. App tracks countable vs excluded assets separately
4. If assets approach $1,800 → warning: ''Review with SSA before saving further''
5. App does NOT give legal advice — flags issues, defers to SSA or benefits counselor

### SSI Income Mode features
- Fixed monthly income: same amount every month (set once, auto-populates)
- SSI pay date: 1st of month (or prior Friday if 1st falls on weekend)
- No income variability tracking needed — income is stable
- No tax filing required for SSI income (SSI is not taxable)
- Asset tracker widget: countable assets vs $2,000 SSI limit with status indicator
- ABLE Account tracking: flagged as excluded from SSI limit, tracked separately

### SSI + Other Income (CRITICAL)
If Braddon earns ANY work income alongside SSI:
- App flags immediately: ''Report this income to SSA within 10 days''
- App calculates estimated SSI reduction: (earned income - $85) / 2
- App never hides or minimizes income — non-reporting is fraud
- YouTube AdSense / app revenue: may count as earned or unearned income depending on SSA classification — app flags for Braddon to verify with SSA
- Bottom line: any income Braddon earns from apps or YouTube MUST be disclosed to SSA

### SSI Asset Limit Tracker (Braddon dashboard widget)
Countable assets running total vs $2,000 limit:
  Green:   under $1,500 (safe)
  Amber:   $1,500-$1,800 (be careful)
  Red:     $1,800-$2,000 (review now)
  Crisis:  over $2,000 (contact SSA immediately)

### App disclaimer shown on Braddon''s SSI screen
''This app helps track finances. SSI rules are complex.
Always report income changes to SSA within 10 days.
Consult a benefits counselor for specific guidance.
This is not legal advice.''

## BRO 1 — W-2 STEADY JOB MODE

### Income characteristics
- Bi-weekly or monthly paycheck, consistent amount
- Direct deposit on predictable schedule
- Taxes withheld at source (W-2) — no quarterly estimates needed
- Most stable, predictable income in the family

### Steady Job Mode features
- Set pay frequency: bi-weekly / semi-monthly / monthly
- Set net take-home (after-tax amount that hits account)
- App auto-populates income on expected pay dates — just confirm arrival
- Teller (deferred): direct deposit auto-detected and logged
- Dashboard: next payday + days away, monthly take-home, YTD total
- Standard expense bucket tracking (fixed + variable)
- NO quarterly tax tracker needed (employer handles withholding)
- Standard debt snowball + FI tracker fully available

### Contribution model for Bro 1
- Most reliable contributor — flat or percentage model works well
- App suggests: schedule household contribution transfer on payday automatically
- Direct deposit predictability = zero friction for consistent contributions

## UPDATED FAMILY TAX COMPLEXITY MATRIX

Member    Mode              Tax Complexity
Braddon   SSI Fixed         None (SSI untaxed) + SSI compliance rules
Bro 1     W-2 Steady        Low (employer withholds, standard refund season)
Mom       Uber Eats Gig     HIGH (self-employment, quarterly payments, mileage)
Dad       Uber Eats Gig     HIGH (self-employment, quarterly payments, mileage)
Bro 2     TBD               TBD',NULL,NULL,'2026-03-17T02:50:36.659Z','2026-03-17T02:53:43.431Z','{}','Family Budget OS — Full Design Spec (Multi-Income, Gig + Mixed Streams)

Full design spec for a 5-member family budget OS — Mom and Dad on Uber Eats gig income, Braddon on app/YouTube revenue, Bro 1 and Bro 2 TBD. Covers Hub+Spoke architecture, privacy tiers, Uber CSV income import, contribution models, runway metric, and tax tracking.

## FAMILY SETUP (corrected March 2026)
Mom    → Uber Eats gig income (chaotic, shift-based)
Dad    → Uber Eats gig income (chaotic, shift-based)
Braddon → App revenue + YouTube AdSense + freelance/other (irregular, project-based)
Bro 1  → TBD income type
Bro 2  → TBD income type

## Architecture: Hub + Spokes
Each person has a private SPOKE — their income, spending, debt, personal data.
The FAMILY HUB shows only what''s relevant to everyone — shared bills, contributions, runway, goals.
Nobody sees each other''s exact numbers — privacy is default, sharing is opt-in.

## Income Input Methods (ranked best to backup)

### Method A — Chase/Teller Auto-Import (DEFERRED — best when ready)
Teller reads Chase deposits. Uber Eats weekly deposits hit Thursday.
App sees "UBER EATS PAYMENT +$247.80" → auto-tags → routes to correct person''s spoke.
YouTube AdSense → Braddon''s spoke. Zero manual entry.

### Method B — Uber CSV Upload (BEST RIGHT NOW — semi-automatic)
Uber Driver app → Earnings → Statements → Download CSV (weekly)
Mom and Dad each download weekly CSV on Sundays, upload to app.
App parses: gross earnings, Uber fees, tips, net take-home, miles driven.
Takes 30 seconds. Fully accurate. Officially supported by Uber.
CSV fields: deliveries count, gross, service fee deduction, tips, net, miles.

### Method C — Weekly Uber Email Parse (semi-automatic)
Uber sends weekly earnings emails. Can IFTTT-forward to a parsing endpoint.
App extracts the total — less detail than CSV but fully automated.

### Method D — Manual Quick Log (always available, 30 seconds)
After each shift: earnings, hours, miles. Backup or mid-week check-in.
Good for seeing where you are mid-week before CSV is available.

### Method E — Apify/Uber API scraping (deferred, not recommended)
Uber Driver API exists but is limited access and complex approval.
CSV method is cleaner, officially supported, and sufficient.

## Uber Eats Payment Schedule
Weekly deposit: Thursday via direct deposit to linked bank (Chase).
Instant Pay: up to 6x per day, $0.85 fee per cash-out.
Earnings cycle: Mon 4am to Mon 3:59am next week.
Wednesday: processed. Thursday: deposited to bank.

## Family Hub Dashboard
Primary metrics:
- Household runway (days until shared bills can''t be covered)
- Contribution status per member (✅/⏳ — no amounts shown to others)
- Shared bills tracker (rent, utilities, groceries, internet)
- Emergency fund progress (family buffer built collectively)

Contribution visibility: amount shown only to contributor + admin. Others see status only.

## Contribution Models

### Option A — Flat Contribution (simplest)
Fixed monthly amounts agreed upfront. Easy to track, predictable.

### Option B — Income Percentage (fairest)
Each contributes X% of their monthly income.
High earners pay more, lower earners pay less, automatically.

### Option C — Gig Flex (Mom + Dad model)
Floor: minimum guaranteed contribution (e.g. $200)
Surplus: when earnings exceed weekly target, flag additional contribution
Slow week: pay floor only, gap covered from emergency fund, repay next good month

## Mom + Dad Gig Unit Features
Both on Uber Eats → tracked as individual spokes OR combined gig unit view.
Combined tracker shows:
- Total combined earnings per week
- Best shift combos (both online Sat dinner avg $210 combined)
- Combined mileage deduction (tracked separately per driver)
- Combined YTD tax deduction estimate

## Tax Handling (critical — Uber does NOT withhold taxes)
Per driver:
- Gross earnings tracked
- Miles driven tracked (deductible at ~$0.67/mile IRS 2025 rate)
- Net taxable income = gross - mileage deduction
- Self-employment tax estimate = ~15% of net
- Quarterly deadlines: Apr 15, Jun 15, Sep 15, Jan 15
- App shows set-aside progress vs owed, days until next quarterly due
- Year-end: typical mileage deduction $500-$2,000 per driver

## Three Bucket System (Mom + Dad income model)
EARN → HOLD → SPEND
Buffer Account: fixed bills always paid from here
Spending Pool: day-to-day variable
Emergency Jar: untouched, true emergencies only

Weekly salary smoothing: set a fixed salary (e.g. $250/week each).
Earn above → surplus to buffer. Earn below → draw from buffer.
This insulates fixed expenses from income chaos.

## Runway Metric (primary gig metric)
Runway = days until buffer hits zero at average burn rate.
Rule: if runway > 14 days → you''re fine. Close the app.
Shown prominently on dashboard. Updated with every CSV upload or manual log.

## Privacy Tiers (each person configures their own)
PRIVATE: full income, debt, personal spending, savings, FI score
CONTRIBUTION: monthly amount + paid/pending status (household sees this)
SHARED (opt-in): income range, financial goal description, gig work status

## Slow Week Protocol (gig workers)
App detects slow week → shows runway (reassurance) → specific recovery options.
"Buffer covers this. No panic." + shift suggestions based on historical patterns.
Slow week notification to household: soft alert, no amounts shown, just heads up.
Options: push hard this week / pay floor only / notify household.

## Family Goals (voted)
Any member proposes a goal. Appears on Hub when majority approves.
Examples: Emergency fund ($500), Better apartment deposit ($5,000), Bro 2 school fund.
Shows: who''s contributing, how much, estimated completion, Claude monthly allocation suggestion.

## Fairness Checker (monthly, Claude-powered)
Audits whether contribution split is fair relative to each person''s income.
Shows effective contribution rate as % of income per person.
Claude surfaces imbalances diplomatically — information, not accusation.

## Braddon''s Spoke (different from gig mode)
Income: app revenue (project-based), YouTube AdSense (monthly), freelance (variable).
Not shift-based → monthly income log rather than per-run log.
YouTube Studio CSV export → monthly earnings import.
App revenue: manual log when payments arrive.
Teller (deferred): AdSense and app payments auto-detected in Chase deposits.

## DB Tables
users (id, name, role, income_type, privacy_level, weekly_salary_target)
contributions (user_id, month, amount, status, model: flat/pct/flex)
shared_bills (name, amount, due_date, paid_by, month)
family_goals (name, target, current, contributors, votes, status)
runs (user_id, date, hours, earnings, miles, platform, shift_type)
buffer (user_id, date, amount, type: deposit/withdrawal, note)
tax_tracker (user_id, year, gross, miles, estimated_owed, set_aside)
transactions (user_id, date, name, amount, category — Teller, deferred)

## Build Order
Session 1: Multi-user auth + profile setup (income type selection)
Session 2: Family Hub (shared bills, contribution tracker, household runway)
Session 3: Individual Spokes (gig mode for Mom+Dad, standard for Braddon)
Session 4: Contribution system (flat/pct/flex, slow week protocol)
Session 5: Uber CSV parser + import flow
Session 6: Tax tracker (per driver mileage + quarterly estimates)
Session 7: Family goals + fairness checker
Session 8: Claude family digest + individual digests
Session 9 (deferred): Teller bank sync per member',NULL,NULL,NULL,'not_chunked');
INSERT OR IGNORE INTO nodes (id,title,description,notes,link,event_date,created_at,updated_at,metadata,chunk,embedding,embedding_updated_at,embedding_text,chunk_status) VALUES (43,'Family Budget OS — SSI & W-2 Income Modes (Deferred)','Deferred design spec for Braddon''s SSI disability mode and Bro 1''s W-2 steady job mode within the Family Budget OS — covers SSI asset limits, reporting rules, ABLE accounts, and direct deposit tracking.','## Status: DEFERRED — build when financially stable and ready

## BRADDON — SSI DISABILITY MODE

### Critical SSI Rules the App Must Enforce
- 2025 SSI max: $943/month individual
- Countable asset limit: $2,000 — exceeding this = loss of eligibility
- App safe zone: warn at $1,500 (amber), $1,800 (red), over $2,000 (crisis — contact SSA)
- App NEVER suggests saving more without flagging the $2,000 limit first
- App tracks countable vs excluded assets separately

### Excluded Assets (not counted against $2,000 limit)
- Primary home
- One vehicle
- Personal belongings
- ABLE account (up to $100,000)
- Life insurance under $1,500 face value

### SSI Income Mode Features
- Fixed monthly income: set once, auto-populates every month
- Pay date: 1st of month (or prior Friday if 1st falls on weekend)
- No income variability tracking needed — SSI is stable
- SSI is NOT taxable — no tax tracker needed for SSI income itself
- Asset tracker widget on dashboard with color-coded status
- ABLE account balance tracked separately as excluded

### SSI + Other Income (CRITICAL — any extra income)
- Any work income (including YouTube AdSense, app revenue) must be reported to SSA within 10 days
- App calculates estimated SSI reduction: (earned income - $85) / 2
- App flags immediately when any other income is logged
- YouTube/app revenue SSA classification is unclear — app always flags to verify with SSA
- App NEVER hides or minimizes income — non-reporting is fraud
- App disclaimer: "This is not legal advice. Contact SSA or a benefits counselor."

### SSI Dashboard Widget
Countable assets: $___
SSI limit:        $2,000
Status:           Green (<$1,500) / Amber ($1,500-$1,800) / Red ($1,800-$2,000) / Crisis (>$2,000)
ABLE Account:     $0 (excluded, tracked separately)
Next SSI payment: [date]

## BRO 1 — W-2 STEADY JOB MODE

### Income Characteristics
- Bi-weekly or monthly paycheck, consistent net amount
- Direct deposit on predictable schedule
- Taxes withheld at source by employer — no quarterly estimates needed
- Most stable, predictable income in the family

### W-2 Mode Features
- Set pay frequency: bi-weekly / semi-monthly / monthly
- Set net take-home (after-tax amount)
- App auto-populates income on expected pay dates — just confirm arrival
- Dashboard: next payday + days away, monthly take-home, YTD total
- Standard expense bucket tracking (fixed + variable)
- No quarterly tax tracker needed
- Standard debt snowball + FI tracker fully available
- Teller (deferred): direct deposit auto-detected in bank account

### Contribution Model
- Most reliable contributor — flat or percentage model works confidently
- App suggestion: schedule household contribution auto-transfer on payday
- Direct deposit predictability = zero friction for consistent contributions

## FULL FAMILY TAX COMPLEXITY MATRIX
Braddon  → SSI Fixed     → None (SSI untaxed) + SSI compliance monitoring
Bro 1    → W-2 Steady    → Low (employer withholds, standard April filing)
Mom      → Uber Eats Gig → HIGH (self-employment + quarterly payments + mileage deductions)
Dad      → Uber Eats Gig → HIGH (self-employment + quarterly payments + mileage deductions)
Bro 2    → TBD           → TBD at setup

## KEY DISCLAIMER TO BUILD INTO APP
Every SSI-related screen shows:
"SSI rules are complex and change. Always report income changes to SSA
within 10 days of receiving them. This app tracks your finances —
it does not provide legal or benefits advice. Consult SSA directly
or contact a benefits counselor / legal aid for specific guidance."',NULL,NULL,'2026-03-17T02:56:13.234Z','2026-03-17T02:56:13.234Z','{}','Family Budget OS — SSI & W-2 Income Modes (Deferred)

Deferred design spec for Braddon''s SSI disability mode and Bro 1''s W-2 steady job mode within the Family Budget OS — covers SSI asset limits, reporting rules, ABLE accounts, and direct deposit tracking.

## Status: DEFERRED — build when financially stable and ready

## BRADDON — SSI DISABILITY MODE

### Critical SSI Rules the App Must Enforce
- 2025 SSI max: $943/month individual
- Countable asset limit: $2,000 — exceeding this = loss of eligibility
- App safe zone: warn at $1,500 (amber), $1,800 (red), over $2,000 (crisis — contact SSA)
- App NEVER suggests saving more without flagging the $2,000 limit first
- App tracks countable vs excluded assets separately

### Excluded Assets (not counted against $2,000 limit)
- Primary home
- One vehicle
- Personal belongings
- ABLE account (up to $100,000)
- Life insurance under $1,500 face value

### SSI Income Mode Features
- Fixed monthly income: set once, auto-populates every month
- Pay date: 1st of month (or prior Friday if 1st falls on weekend)
- No income variability tracking needed — SSI is stable
- SSI is NOT taxable — no tax tracker needed for SSI income itself
- Asset tracker widget on dashboard with color-coded status
- ABLE account balance tracked separately as excluded

### SSI + Other Income (CRITICAL — any extra income)
- Any work income (including YouTube AdSense, app revenue) must be reported to SSA within 10 days
- App calculates estimated SSI reduction: (earned income - $85) / 2
- App flags immediately when any other income is logged
- YouTube/app revenue SSA classification is unclear — app always flags to verify with SSA
- App NEVER hides or minimizes income — non-reporting is fraud
- App disclaimer: "This is not legal advice. Contact SSA or a benefits counselor."

### SSI Dashboard Widget
Countable assets: $___
SSI limit:        $2,000
Status:           Green (<$1,500) / Amber ($1,500-$1,800) / Red ($1,800-$2,000) / Crisis (>$2,000)
ABLE Account:     $0 (excluded, tracked separately)
Next SSI payment: [date]

## BRO 1 — W-2 STEADY JOB MODE

### Income Characteristics
- Bi-weekly or monthly paycheck, consistent net amount
- Direct deposit on predictable schedule
- Taxes withheld at source by employer — no quarterly estimates needed
- Most stable, predictable income in the family

### W-2 Mode Features
- Set pay frequency: bi-weekly / semi-monthly / monthly
- Set net take-home (after-tax amount)
- App auto-populates income on expected pay dates — just confirm arrival
- Dashboard: next payday + days away, monthly take-home, YTD total
- Standard expense bucket tracking (fixed + variable)
- No quarterly tax tracker needed
- Standard debt snowball + FI tracker fully available
- Teller (deferred): direct deposit auto-detected in bank account

### Contribution Model
- Most reliable contributor — flat or percentage model works confidently
- App suggestion: schedule household contribution auto-transfer on payday
- Direct deposit predictability = zero friction for consistent contributions

## FULL FAMILY TAX COMPLEXITY MATRIX
Braddon  → SSI Fixed     → None (SSI untaxed) + SSI compliance monitoring
Bro 1    → W-2 Steady    → Low (employer withholds, standard April filing)
Mom      → Uber Eats Gig → HIGH (self-employment + quarterly payments + mileage deductions)
Dad      → Uber Eats Gig → HIGH (self-employment + quarterly payments + mileage deductions)
Bro 2    → TBD           → TBD at setup

## KEY DISCLAIMER TO BUILD INTO APP
Every SSI-related screen shows:
"SSI rules are complex and change. Always report income changes to SSA
within 10 days of receiving them. This app tracks your finances —
it does not provide legal or benefits advice. Consult SSA directly
or contact a benefits counselor / legal aid for specific guidance."',NULL,NULL,NULL,'not_chunked');
INSERT OR IGNORE INTO nodes (id,title,description,notes,link,event_date,created_at,updated_at,metadata,chunk,embedding,embedding_updated_at,embedding_text,chunk_status) VALUES (44,'Family Budget OS — Family Summary (Shareable)','Plain-English family pitch for the Family Budget OS — covers each member''s income mode, what''s shared vs private, how income gets in, and key features. Designed to get the family on board.','## Family member income modes

Braddon   → SSI Disability — fixed monthly, app protects the $2,000 asset limit automatically
Bro 1     → W-2 steady job — direct deposit, app knows pay schedule, one tap to confirm
Mom       → Uber Eats gig — weekly CSV upload Sundays, app reads earnings/tips/miles
Dad       → Uber Eats gig — same as Mom, tracked separately + combined view available
Bro 2     → TBD — picks income type at setup, app adapts

## What everyone sees together (Family Hub)
- Household runway (days until bills can''t be covered)
- Shared bills status (rent, utilities, groceries, internet)
- Contribution status per person — ✅ paid / ⏳ pending (NO amounts visible to others)
- Emergency fund progress
- Family goals (voted, shared)

## What stays private (each person''s Spoke)
- Exact income amount
- Personal spending
- Debt details
- Savings amount
- FI score / asset tracker

## How income gets in (simple as possible)
1. Mom + Dad: Uber app → Earnings → Download CSV → upload to app (30 seconds, Sundays)
2. Bro 1: App knows pay schedule — one tap to confirm direct deposit arrived
3. Braddon: SSI set once, auto-populates on the 1st every month
4. Later upgrade: Chase/Teller bank sync — everything auto-imports, no CSV needed

## Key features
- Household runway: days until bills can''t be covered — the number that matters for gig workers
- Uber CSV parser: reads gross, fees, tips, net, miles automatically
- Tax tracker: Mom + Dad owe quarterly self-employment tax — app tracks and reminds
- SSI asset guard: warns Braddon before savings approach $2,000 SSI limit
- Slow week mode: bad Uber week? App shows runway, says if it''s fine, suggests shifts
- Family goals: emergency fund, apartment deposit, school fund — voted, tracked together
- Fairness checker: Claude audits monthly whether contribution split is fair by income %

## Core message for family
"Nobody sees each other''s personal numbers — only whether you''ve contributed to the household.
The app is a calm, honest mirror of our shared finances. No judgment, no drama — just clarity."

## Privacy rule
Amount shown only to the contributor + admin (Braddon as builder).
Others see status only: paid or pending. Nothing else unless person opts in to share.',NULL,NULL,'2026-03-17T02:59:37.400Z','2026-03-17T02:59:37.400Z','{}','Family Budget OS — Family Summary (Shareable)

Plain-English family pitch for the Family Budget OS — covers each member''s income mode, what''s shared vs private, how income gets in, and key features. Designed to get the family on board.

## Family member income modes

Braddon   → SSI Disability — fixed monthly, app protects the $2,000 asset limit automatically
Bro 1     → W-2 steady job — direct deposit, app knows pay schedule, one tap to confirm
Mom       → Uber Eats gig — weekly CSV upload Sundays, app reads earnings/tips/miles
Dad       → Uber Eats gig — same as Mom, tracked separately + combined view available
Bro 2     → TBD — picks income type at setup, app adapts

## What everyone sees together (Family Hub)
- Household runway (days until bills can''t be covered)
- Shared bills status (rent, utilities, groceries, internet)
- Contribution status per person — ✅ paid / ⏳ pending (NO amounts visible to others)
- Emergency fund progress
- Family goals (voted, shared)

## What stays private (each person''s Spoke)
- Exact income amount
- Personal spending
- Debt details
- Savings amount
- FI score / asset tracker

## How income gets in (simple as possible)
1. Mom + Dad: Uber app → Earnings → Download CSV → upload to app (30 seconds, Sundays)
2. Bro 1: App knows pay schedule — one tap to confirm direct deposit arrived
3. Braddon: SSI set once, auto-populates on the 1st every month
4. Later upgrade: Chase/Teller bank sync — everything auto-imports, no CSV needed

## Key features
- Household runway: days until bills can''t be covered — the number that matters for gig workers
- Uber CSV parser: reads gross, fees, tips, net, miles automatically
- Tax tracker: Mom + Dad owe quarterly self-employment tax — app tracks and reminds
- SSI asset guard: warns Braddon before savings approach $2,000 SSI limit
- Slow week mode: bad Uber week? App shows runway, says if it''s fine, suggests shifts
- Family goals: emergency fund, apartment deposit, school fund — voted, tracked together
- Fairness checker: Claude audits monthly whether contribution split is fair by income %

## Core message for family
"Nobody sees each other''s personal numbers — only whether you''ve contributed to the household.
The app is a calm, honest mirror of our shared finances. No judgment, no drama — just clarity."

## Privacy rule
Amount shown only to the contributor + admin (Braddon as builder).
Others see status only: paid or pending. Nothing else unless person opts in to share.',NULL,NULL,NULL,'not_chunked');
INSERT OR IGNORE INTO nodes (id,title,description,notes,link,event_date,created_at,updated_at,metadata,chunk,embedding,embedding_updated_at,embedding_text,chunk_status) VALUES (45,'Claude Code Global CLAUDE.md — RA-H Auto-Save Rule','Global Claude Code instruction file at ~/.claude/CLAUDE.md — forces Claude Code to propose an RA-H node save after every completed build, feature, or fix across all sessions and projects.','## File location
~/.claude/CLAUDE.md (global — applies to ALL Claude Code sessions on this machine)

## What it does
Every time Claude Code finishes building anything, it is required to:
1. Summarize what was built in one sentence
2. Identify which RA-H nodes it connects to
3. Propose a node (title, description, content, connections)
4. Ask: "Want me to create this node now?"

## Rule text
After completing ANY piece of work — file, feature, route, component, fix, config, or meaningful update — before moving to the next task:
- Summarize what was just built
- Identify related RA-H nodes
- Propose the node structure
- Ask to save

Do NOT wait until end of session.
Do NOT skip for small fixes.
Treat RA-H as a living record of everything built.

## Current projects included as context
- Open Notebook (localhost:8502) — running
- Open Notebook Clipper — built and live in Chrome
- Prometheus — Next.js Phase 1 done
- Stridemon — React walking game, active
- Family Budget OS — planned
- Grocery Tracker — Flask, deployed on Railway

## Stack reference included
Flask/SQLite, Next.js 14/TypeScript/Tailwind, React JSX, Railway, Claude API, Teller.io',NULL,NULL,'2026-03-17T18:35:19.749Z','2026-03-17T18:35:19.749Z','{}','Claude Code Global CLAUDE.md — RA-H Auto-Save Rule

Global Claude Code instruction file at ~/.claude/CLAUDE.md — forces Claude Code to propose an RA-H node save after every completed build, feature, or fix across all sessions and projects.

## File location
~/.claude/CLAUDE.md (global — applies to ALL Claude Code sessions on this machine)

## What it does
Every time Claude Code finishes building anything, it is required to:
1. Summarize what was built in one sentence
2. Identify which RA-H nodes it connects to
3. Propose a node (title, description, content, connections)
4. Ask: "Want me to create this node now?"

## Rule text
After completing ANY piece of work — file, feature, route, component, fix, config, or meaningful update — before moving to the next task:
- Summarize what was just built
- Identify related RA-H nodes
- Propose the node structure
- Ask to save

Do NOT wait until end of session.
Do NOT skip for small fixes.
Treat RA-H as a living record of everything built.

## Current projects included as context
- Open Notebook (localhost:8502) — running
- Open Notebook Clipper — built and live in Chrome
- Prometheus — Next.js Phase 1 done
- Stridemon — React walking game, active
- Family Budget OS — planned
- Grocery Tracker — Flask, deployed on Railway

## Stack reference included
Flask/SQLite, Next.js 14/TypeScript/Tailwind, React JSX, Railway, Claude API, Teller.io',NULL,NULL,NULL,'not_chunked');
INSERT OR IGNORE INTO nodes (id,title,description,notes,link,event_date,created_at,updated_at,metadata,chunk,embedding,embedding_updated_at,embedding_text,chunk_status) VALUES (46,'RA-H Cross-Device Access Guide','Reference guide for accessing the RA-H knowledge graph from any device — phone, tablet, or another computer — without needing the main machine running.','## Does the main computer need to be on? NO.

RA-H graph data lives on Anthropic''s servers tied to your Claude.ai account — not on your local machine.
Your local machine only runs Claude Code + MCP tools. The graph itself is always online.

## Access Methods by Device

### Phone (works right now, no setup)
- Open Claude app or claude.ai in mobile browser
- Log into your Anthropic account
- All 45 nodes, all 91 edges, all memories are there instantly
- Ask Claude to read, search, or add nodes — works fully from chat
- Limitation: no Claude Code MCP tools on phone (can''t run terminal)

### Another Computer (full access including Claude Code)
Step 1: Install Claude Code
  npm install -g @anthropic-ai/claude-code

Step 2: Copy two files from main machine:
  ~/.claude/CLAUDE.md  (RA-H auto-save rules + project context)
  ~/.claude/claude_mcp_config.json  (RA-H MCP connection + API key)

Step 3: Log in
  claude login

Done — same graph, same MCP tools, full Claude Code access.

Step 4 (optional): Copy project folders if needed
  open-notebook-clipper/
  prometheus-next/
  Any other active project folders

## What lives WHERE

ON ANTHROPIC''S SERVERS (always accessible, no machine needed):
- Your RA-H graph (all nodes, edges, dimensions)
- Your Claude.ai memories
- Your conversation history

ON YOUR LOCAL MACHINE ONLY:
- ~/.claude/CLAUDE.md (global auto-save rules)
- ~/.claude/claude_mcp_config.json (MCP connection config)
- Docker + Open Notebook (localhost:8502) — needs machine ON
- Project files (code, folders)
- Claude Code terminal sessions

## Open Notebook caveat
Open Notebook runs at localhost:8502 via Docker.
This DOES require your main machine to be on and Docker running.
To access Open Notebook from other devices:
Option A: Deploy to Railway (same as grocery tracker) — always online
Option B: Use ngrok to tunnel localhost:8502 temporarily
Option C: Keep main machine on when you need it

## Summary
RA-H graph: always accessible from any device, machine off = fine
Claude.ai chat on phone: works fully, machine off = fine
Claude Code on another computer: copy 2 files, works fully
Open Notebook: needs main machine on OR deploy to Railway',NULL,NULL,'2026-03-17T19:19:25.804Z','2026-03-17T19:19:25.804Z','{}','RA-H Cross-Device Access Guide

Reference guide for accessing the RA-H knowledge graph from any device — phone, tablet, or another computer — without needing the main machine running.

## Does the main computer need to be on? NO.

RA-H graph data lives on Anthropic''s servers tied to your Claude.ai account — not on your local machine.
Your local machine only runs Claude Code + MCP tools. The graph itself is always online.

## Access Methods by Device

### Phone (works right now, no setup)
- Open Claude app or claude.ai in mobile browser
- Log into your Anthropic account
- All 45 nodes, all 91 edges, all memories are there instantly
- Ask Claude to read, search, or add nodes — works fully from chat
- Limitation: no Claude Code MCP tools on phone (can''t run terminal)

### Another Computer (full access including Claude Code)
Step 1: Install Claude Code
  npm install -g @anthropic-ai/claude-code

Step 2: Copy two files from main machine:
  ~/.claude/CLAUDE.md  (RA-H auto-save rules + project context)
  ~/.claude/claude_mcp_config.json  (RA-H MCP connection + API key)

Step 3: Log in
  claude login

Done — same graph, same MCP tools, full Claude Code access.

Step 4 (optional): Copy project folders if needed
  open-notebook-clipper/
  prometheus-next/
  Any other active project folders

## What lives WHERE

ON ANTHROPIC''S SERVERS (always accessible, no machine needed):
- Your RA-H graph (all nodes, edges, dimensions)
- Your Claude.ai memories
- Your conversation history

ON YOUR LOCAL MACHINE ONLY:
- ~/.claude/CLAUDE.md (global auto-save rules)
- ~/.claude/claude_mcp_config.json (MCP connection config)
- Docker + Open Notebook (localhost:8502) — needs machine ON
- Project files (code, folders)
- Claude Code terminal sessions

## Open Notebook caveat
Open Notebook runs at localhost:8502 via Docker.
This DOES require your main machine to be on and Docker running.
To access Open Notebook from other devices:
Option A: Deploy to Railway (same as grocery tracker) — always online
Option B: Use ngrok to tunnel localhost:8502 temporarily
Option C: Keep main machine on when you need it

## Summary
RA-H graph: always accessible from any device, machine off = fine
Claude.ai chat on phone: works fully, machine off = fine
Claude Code on another computer: copy 2 files, works fully
Open Notebook: needs main machine on OR deploy to Railway',NULL,NULL,NULL,'not_chunked');

INSERT OR IGNORE INTO edges (id,from_node_id,to_node_id,source,created_at,context) VALUES (1,1,2,'mcp','2026-03-16T10:36:21.933Z','{"type":"related_to","confidence":0.5,"inferred_at":"2026-03-16T10:36:21.933Z","explanation":"is actively building games with","created_via":"mcp"}');
INSERT OR IGNORE INTO edges (id,from_node_id,to_node_id,source,created_at,context) VALUES (2,1,3,'mcp','2026-03-16T10:36:22.868Z','{"type":"related_to","confidence":0.5,"inferred_at":"2026-03-16T10:36:22.868Z","explanation":"creates and runs YouTube content about","created_via":"mcp"}');
INSERT OR IGNORE INTO edges (id,from_node_id,to_node_id,source,created_at,context) VALUES (3,1,4,'mcp','2026-03-16T10:36:23.573Z','{"type":"related_to","confidence":0.5,"inferred_at":"2026-03-16T10:36:23.573Z","explanation":"actively practices and creates","created_via":"mcp"}');
INSERT OR IGNORE INTO edges (id,from_node_id,to_node_id,source,created_at,context) VALUES (4,1,5,'mcp','2026-03-16T10:36:24.541Z','{"type":"related_to","confidence":0.5,"inferred_at":"2026-03-16T10:36:24.541Z","explanation":"researches and follows closely, especially Claude/Anthropic","created_via":"mcp"}');
INSERT OR IGNORE INTO edges (id,from_node_id,to_node_id,source,created_at,context) VALUES (5,1,6,'mcp','2026-03-16T10:36:25.321Z','{"type":"related_to","confidence":0.5,"inferred_at":"2026-03-16T10:36:25.321Z","explanation":"actively studies and invests in","created_via":"mcp"}');
INSERT OR IGNORE INTO edges (id,from_node_id,to_node_id,source,created_at,context) VALUES (6,5,2,'mcp','2026-03-16T10:36:28.537Z','{"type":"related_to","confidence":0.5,"inferred_at":"2026-03-16T10:36:28.537Z","explanation":"informs game development through AI-assisted tools and trends","created_via":"mcp"}');
INSERT OR IGNORE INTO edges (id,from_node_id,to_node_id,source,created_at,context) VALUES (7,5,4,'mcp','2026-03-16T10:36:29.160Z','{"type":"related_to","confidence":0.5,"inferred_at":"2026-03-16T10:36:29.160Z","explanation":"augments creative writing through generative AI tools and inspiration","created_via":"mcp"}');
INSERT OR IGNORE INTO edges (id,from_node_id,to_node_id,source,created_at,context) VALUES (8,8,9,'mcp','2026-03-16T11:14:00.838Z','{"type":"related_to","confidence":0.5,"inferred_at":"2026-03-16T11:14:00.838Z","explanation":"contains the Kroger API + Claude AI search logic","created_via":"mcp"}');
INSERT OR IGNORE INTO edges (id,from_node_id,to_node_id,source,created_at,context) VALUES (9,8,10,'mcp','2026-03-16T11:14:01.943Z','{"type":"related_to","confidence":0.5,"inferred_at":"2026-03-16T11:14:01.943Z","explanation":"uses as its entire SQLite data layer","created_via":"mcp"}');
INSERT OR IGNORE INTO edges (id,from_node_id,to_node_id,source,created_at,context) VALUES (10,8,11,'mcp','2026-03-16T11:14:02.776Z','{"type":"related_to","confidence":0.5,"inferred_at":"2026-03-16T11:14:02.776Z","explanation":"ships alongside as a Chrome extension for recipe capture","created_via":"mcp"}');
INSERT OR IGNORE INTO edges (id,from_node_id,to_node_id,source,created_at,context) VALUES (11,8,12,'mcp','2026-03-16T11:14:03.418Z','{"type":"related_to","confidence":0.5,"inferred_at":"2026-03-16T11:14:03.418Z","explanation":"contains the weekly meal budget planner routes","created_via":"mcp"}');
INSERT OR IGNORE INTO edges (id,from_node_id,to_node_id,source,created_at,context) VALUES (12,8,13,'mcp','2026-03-16T11:14:04.004Z','{"type":"related_to","confidence":0.5,"inferred_at":"2026-03-16T11:14:04.004Z","explanation":"contains the quick shopping list and purchase frequency routes","created_via":"mcp"}');
INSERT OR IGNORE INTO edges (id,from_node_id,to_node_id,source,created_at,context) VALUES (13,14,2,'mcp','2026-03-16T12:24:46.695Z','{"type":"related_to","confidence":0.5,"inferred_at":"2026-03-16T12:24:46.695Z","explanation":"is a game dev project being actively built, expanding beyond Godot into React-based game design","created_via":"mcp"}');
INSERT OR IGNORE INTO edges (id,from_node_id,to_node_id,source,created_at,context) VALUES (14,15,14,'mcp','2026-03-16T12:24:50.444Z','{"type":"related_to","confidence":0.5,"inferred_at":"2026-03-16T12:24:50.444Z","explanation":"defines the visual identity and repeatable drawing formula for all 15 creatures in this project","created_via":"mcp"}');
INSERT OR IGNORE INTO edges (id,from_node_id,to_node_id,source,created_at,context) VALUES (15,15,2,'mcp','2026-03-16T12:24:54.242Z','{"type":"related_to","confidence":0.5,"inferred_at":"2026-03-16T12:24:54.242Z","explanation":"is part of the broader game development practice and creative output","created_via":"mcp"}');
INSERT OR IGNORE INTO edges (id,from_node_id,to_node_id,source,created_at,context) VALUES (16,16,17,'mcp','2026-03-16T17:13:14.003Z','{"type":"related_to","confidence":0.5,"inferred_at":"2026-03-16T17:13:14.003Z","explanation":"is implemented by the zero-cost architecture defined in","created_via":"mcp"}');
INSERT OR IGNORE INTO edges (id,from_node_id,to_node_id,source,created_at,context) VALUES (17,16,18,'mcp','2026-03-16T17:13:15.161Z','{"type":"related_to","confidence":0.5,"inferred_at":"2026-03-16T17:13:15.161Z","explanation":"pulls its card content from the sources catalogued in","created_via":"mcp"}');
INSERT OR IGNORE INTO edges (id,from_node_id,to_node_id,source,created_at,context) VALUES (18,19,16,'mcp','2026-03-16T17:13:15.802Z','{"type":"related_to","confidence":0.5,"inferred_at":"2026-03-16T17:13:15.802Z","explanation":"lists EduScroll as the primary build candidate among the app ideas in","created_via":"mcp"}');
INSERT OR IGNORE INTO edges (id,from_node_id,to_node_id,source,created_at,context) VALUES (19,16,1,'mcp','2026-03-16T17:13:16.429Z','{"type":"related_to","confidence":0.5,"inferred_at":"2026-03-16T17:13:16.429Z","explanation":"is a personal app being designed and built by","created_via":"mcp"}');
INSERT OR IGNORE INTO edges (id,from_node_id,to_node_id,source,created_at,context) VALUES (20,16,5,'mcp','2026-03-16T17:13:19.635Z','{"type":"related_to","confidence":0.5,"inferred_at":"2026-03-16T17:13:19.635Z","explanation":"uses Claude as its core AI engine, directly extending the interests tracked in","created_via":"mcp"}');
INSERT OR IGNORE INTO edges (id,from_node_id,to_node_id,source,created_at,context) VALUES (21,19,1,'mcp','2026-03-16T17:13:19.684Z','{"type":"related_to","confidence":0.5,"inferred_at":"2026-03-16T17:13:19.684Z","explanation":"maps the full RA-H-powered app ecosystem Huge Papa plans to build","created_via":"mcp"}');
INSERT OR IGNORE INTO edges (id,from_node_id,to_node_id,source,created_at,context) VALUES (22,20,16,'mcp','2026-03-16T20:42:26.151Z','{"type":"related_to","confidence":0.5,"inferred_at":"2026-03-16T20:42:26.151Z","explanation":"governs all development and feature decisions for","created_via":"mcp"}');
INSERT OR IGNORE INTO edges (id,from_node_id,to_node_id,source,created_at,context) VALUES (23,20,17,'mcp','2026-03-16T20:42:28.897Z','{"type":"related_to","confidence":0.5,"inferred_at":"2026-03-16T20:42:28.897Z","explanation":"governs all architecture and stack choices defined in","created_via":"mcp"}');
INSERT OR IGNORE INTO edges (id,from_node_id,to_node_id,source,created_at,context) VALUES (24,20,18,'mcp','2026-03-16T20:42:32.025Z','{"type":"related_to","confidence":0.5,"inferred_at":"2026-03-16T20:42:32.025Z","explanation":"governs all content source and API choices catalogued in","created_via":"mcp"}');
INSERT OR IGNORE INTO edges (id,from_node_id,to_node_id,source,created_at,context) VALUES (25,21,16,'mcp','2026-03-16T21:03:28.755Z','{"type":"related_to","confidence":0.5,"inferred_at":"2026-03-16T21:03:28.755Z","explanation":"documents all planning decisions and build instructions for","created_via":"mcp"}');
INSERT OR IGNORE INTO edges (id,from_node_id,to_node_id,source,created_at,context) VALUES (26,21,17,'mcp','2026-03-16T21:03:31.235Z','{"type":"related_to","confidence":0.5,"inferred_at":"2026-03-16T21:03:31.235Z","explanation":"confirms and expands the architecture decisions made in","created_via":"mcp"}');
INSERT OR IGNORE INTO edges (id,from_node_id,to_node_id,source,created_at,context) VALUES (27,21,18,'mcp','2026-03-16T21:03:35.876Z','{"type":"related_to","confidence":0.5,"inferred_at":"2026-03-16T21:03:35.876Z","explanation":"references the content source map established in","created_via":"mcp"}');
INSERT OR IGNORE INTO edges (id,from_node_id,to_node_id,source,created_at,context) VALUES (28,21,20,'mcp','2026-03-16T21:03:41.226Z','{"type":"related_to","confidence":0.5,"inferred_at":"2026-03-16T21:03:41.226Z","explanation":"was built under the rules and constraints defined in","created_via":"mcp"}');
INSERT OR IGNORE INTO edges (id,from_node_id,to_node_id,source,created_at,context) VALUES (29,22,4,'mcp','2026-03-16T23:50:09.655Z','{"type":"related_to","confidence":0.5,"inferred_at":"2026-03-16T23:50:09.655Z","explanation":"provides philosophical frameworks (stoicism, existentialism) as lyrical themes and metaphors for","created_via":"mcp"}');
INSERT OR IGNORE INTO edges (id,from_node_id,to_node_id,source,created_at,context) VALUES (30,22,2,'mcp','2026-03-16T23:50:11.493Z','{"type":"related_to","confidence":0.5,"inferred_at":"2026-03-16T23:50:11.493Z","explanation":"informs moral dilemma design, NPC ethics, and narrative depth in","created_via":"mcp"}');
INSERT OR IGNORE INTO edges (id,from_node_id,to_node_id,source,created_at,context) VALUES (31,22,6,'mcp','2026-03-16T23:50:13.419Z','{"type":"related_to","confidence":0.5,"inferred_at":"2026-03-16T23:50:13.419Z","explanation":"grounds stoic and mindfulness practices that feed into","created_via":"mcp"}');
INSERT OR IGNORE INTO edges (id,from_node_id,to_node_id,source,created_at,context) VALUES (32,22,5,'mcp','2026-03-16T23:50:15.613Z','{"type":"related_to","confidence":0.5,"inferred_at":"2026-03-16T23:50:15.613Z","explanation":"raises philosophy of mind and AI ethics questions that extend into","created_via":"mcp"}');
INSERT OR IGNORE INTO edges (id,from_node_id,to_node_id,source,created_at,context) VALUES (33,23,2,'mcp','2026-03-16T23:50:18.979Z','{"type":"related_to","confidence":0.5,"inferred_at":"2026-03-16T23:50:18.979Z","explanation":"supplies visual storytelling techniques and power system design patterns for","created_via":"mcp"}');
INSERT OR IGNORE INTO edges (id,from_node_id,to_node_id,source,created_at,context) VALUES (34,23,14,'mcp','2026-03-16T23:50:22.642Z','{"type":"related_to","confidence":0.5,"inferred_at":"2026-03-16T23:50:22.642Z","explanation":"informs creature origin stories, power hierarchies, and comic-style lore writing for","created_via":"mcp"}');
INSERT OR IGNORE INTO edges (id,from_node_id,to_node_id,source,created_at,context) VALUES (35,23,4,'mcp','2026-03-16T23:50:25.634Z','{"type":"related_to","confidence":0.5,"inferred_at":"2026-03-16T23:50:25.634Z","explanation":"provides hero/villain archetypes and cinematic narrative voice for","created_via":"mcp"}');
INSERT OR IGNORE INTO edges (id,from_node_id,to_node_id,source,created_at,context) VALUES (36,23,3,'mcp','2026-03-16T23:50:29.697Z','{"type":"related_to","confidence":0.5,"inferred_at":"2026-03-16T23:50:29.697Z","explanation":"offers potential MCU/DC analysis content as cross-niche expansion for","created_via":"mcp"}');
INSERT OR IGNORE INTO edges (id,from_node_id,to_node_id,source,created_at,context) VALUES (37,23,22,'mcp','2026-03-16T23:50:33.937Z','{"type":"related_to","confidence":0.5,"inferred_at":"2026-03-16T23:50:33.937Z","explanation":"explores ethics of heroism and alter-ego identity as philosophical concepts that connect to","created_via":"mcp"}');
INSERT OR IGNORE INTO edges (id,from_node_id,to_node_id,source,created_at,context) VALUES (38,1,22,'mcp','2026-03-16T23:50:39.025Z','{"type":"related_to","confidence":0.5,"inferred_at":"2026-03-16T23:50:39.025Z","explanation":"is the identity anchor that grounds all interests including the new domains of","created_via":"mcp"}');
INSERT OR IGNORE INTO edges (id,from_node_id,to_node_id,source,created_at,context) VALUES (39,22,18,'mcp','2026-03-16T23:51:21.780Z','{"type":"related_to","confidence":0.5,"inferred_at":"2026-03-16T23:51:21.780Z","explanation":"provides philosophy content sources (SEP, Daily Stoic, Partially Examined Life) for the Prometheus card pipeline documented in","created_via":"mcp"}');
INSERT OR IGNORE INTO edges (id,from_node_id,to_node_id,source,created_at,context) VALUES (40,23,18,'mcp','2026-03-16T23:51:23.669Z','{"type":"related_to","confidence":0.5,"inferred_at":"2026-03-16T23:51:23.669Z","explanation":"provides comics and superhero news sources (Marvel/DC RSS, CBR, r/Marvel) for the Prometheus card pipeline documented in","created_via":"mcp"}');
INSERT OR IGNORE INTO edges (id,from_node_id,to_node_id,source,created_at,context) VALUES (41,22,1,'mcp','2026-03-16T23:51:25.789Z','{"type":"related_to","confidence":0.5,"inferred_at":"2026-03-16T23:51:25.789Z","explanation":"is a core interest domain that fully grounds the identity of","created_via":"mcp"}');
INSERT OR IGNORE INTO edges (id,from_node_id,to_node_id,source,created_at,context) VALUES (42,23,1,'mcp','2026-03-16T23:51:27.724Z','{"type":"related_to","confidence":0.5,"inferred_at":"2026-03-16T23:51:27.724Z","explanation":"is a core interest domain that fully grounds the identity of","created_via":"mcp"}');
INSERT OR IGNORE INTO edges (id,from_node_id,to_node_id,source,created_at,context) VALUES (43,24,5,'mcp','2026-03-16T23:57:41.557Z','{"type":"related_to","confidence":0.5,"inferred_at":"2026-03-16T23:57:41.557Z","explanation":"is a key tool in the AI research assistant landscape that directly informs and contextualizes","created_via":"mcp"}');
INSERT OR IGNORE INTO edges (id,from_node_id,to_node_id,source,created_at,context) VALUES (44,24,19,'mcp','2026-03-16T23:57:43.885Z','{"type":"related_to","confidence":0.5,"inferred_at":"2026-03-16T23:57:43.885Z","explanation":"serves as a complementary intake/research tool whose outputs (insights, summaries) can be saved as nodes into","created_via":"mcp"}');
INSERT OR IGNORE INTO edges (id,from_node_id,to_node_id,source,created_at,context) VALUES (45,24,16,'mcp','2026-03-16T23:57:45.960Z','{"type":"related_to","confidence":0.5,"inferred_at":"2026-03-16T23:57:45.960Z","explanation":"represents a competing/parallel approach to personalized knowledge surfacing that benchmarks the vision of","created_via":"mcp"}');
INSERT OR IGNORE INTO edges (id,from_node_id,to_node_id,source,created_at,context) VALUES (46,25,24,'mcp','2026-03-17T00:01:18.805Z','{"type":"related_to","confidence":0.5,"inferred_at":"2026-03-17T00:01:18.805Z","explanation":"is the self-hosted implementation of the tool documented in","created_via":"mcp"}');
INSERT OR IGNORE INTO edges (id,from_node_id,to_node_id,source,created_at,context) VALUES (47,25,26,'mcp','2026-03-17T00:42:23.123Z','{"type":"related_to","confidence":0.5,"inferred_at":"2026-03-17T00:42:23.123Z","explanation":"is the primary intake tool powering the daily consumption workflow described in","created_via":"mcp"}');
INSERT OR IGNORE INTO edges (id,from_node_id,to_node_id,source,created_at,context) VALUES (48,16,26,'mcp','2026-03-17T00:42:25.224Z','{"type":"related_to","confidence":0.5,"inferred_at":"2026-03-17T00:42:25.224Z","explanation":"serves as the passive feed and mid-session capture layer in","created_via":"mcp"}');
INSERT OR IGNORE INTO edges (id,from_node_id,to_node_id,source,created_at,context) VALUES (49,14,26,'mcp','2026-03-17T00:42:27.425Z','{"type":"related_to","confidence":0.5,"inferred_at":"2026-03-17T00:42:27.425Z","explanation":"walking sessions are the highest-leverage audio consumption window identified in","created_via":"mcp"}');
INSERT OR IGNORE INTO edges (id,from_node_id,to_node_id,source,created_at,context) VALUES (50,1,26,'mcp','2026-03-17T00:42:30.881Z','{"type":"related_to","confidence":0.5,"inferred_at":"2026-03-17T00:42:30.881Z","explanation":"is the persistent synthesis layer that receives all captured insights from","created_via":"mcp"}');
INSERT OR IGNORE INTO edges (id,from_node_id,to_node_id,source,created_at,context) VALUES (51,26,27,'mcp','2026-03-17T00:45:22.639Z','{"type":"related_to","confidence":0.5,"inferred_at":"2026-03-17T00:45:22.639Z","explanation":"is the strategic priority that must be executed before returning to building","created_via":"mcp"}');
INSERT OR IGNORE INTO edges (id,from_node_id,to_node_id,source,created_at,context) VALUES (52,28,25,'mcp','2026-03-17T00:47:26.291Z','{"type":"related_to","confidence":0.5,"inferred_at":"2026-03-17T00:47:26.291Z","explanation":"documents all methods for feeding content into the tool described in","created_via":"mcp"}');
INSERT OR IGNORE INTO edges (id,from_node_id,to_node_id,source,created_at,context) VALUES (53,28,26,'mcp','2026-03-17T00:47:28.256Z','{"type":"related_to","confidence":0.5,"inferred_at":"2026-03-17T00:47:28.256Z","explanation":"is the intake action layer that executes the consumption workflow described in","created_via":"mcp"}');
INSERT OR IGNORE INTO edges (id,from_node_id,to_node_id,source,created_at,context) VALUES (54,29,25,'mcp','2026-03-17T00:51:09.248Z','{"type":"related_to","confidence":0.5,"inferred_at":"2026-03-17T00:51:09.248Z","explanation":"is a Chrome extension built to feed content directly into","created_via":"mcp"}');
INSERT OR IGNORE INTO edges (id,from_node_id,to_node_id,source,created_at,context) VALUES (55,29,26,'mcp','2026-03-17T00:51:11.174Z','{"type":"related_to","confidence":0.5,"inferred_at":"2026-03-17T00:51:11.174Z","explanation":"eliminates the last friction point in the intake pipeline described in","created_via":"mcp"}');
INSERT OR IGNORE INTO edges (id,from_node_id,to_node_id,source,created_at,context) VALUES (56,29,11,'mcp','2026-03-17T00:51:13.520Z','{"type":"related_to","confidence":0.5,"inferred_at":"2026-03-17T00:51:13.520Z","explanation":"uses the same grab-page-POST-to-backend architecture as","created_via":"mcp"}');
INSERT OR IGNORE INTO edges (id,from_node_id,to_node_id,source,created_at,context) VALUES (57,31,25,'mcp','2026-03-17T01:19:05.022Z','{"type":"related_to","confidence":0.5,"inferred_at":"2026-03-17T01:19:05.022Z","explanation":"documents the five concrete use cases for the tool described in","created_via":"mcp"}');
INSERT OR IGNORE INTO edges (id,from_node_id,to_node_id,source,created_at,context) VALUES (58,31,28,'mcp','2026-03-17T01:19:07.472Z','{"type":"related_to","confidence":0.5,"inferred_at":"2026-03-17T01:19:07.472Z","explanation":"is the output layer that gives purpose and direction to","created_via":"mcp"}');
INSERT OR IGNORE INTO edges (id,from_node_id,to_node_id,source,created_at,context) VALUES (59,31,26,'mcp','2026-03-17T01:19:10.128Z','{"type":"related_to","confidence":0.5,"inferred_at":"2026-03-17T01:19:10.128Z","explanation":"defines the downstream value that justifies the consumption workflow detailed in","created_via":"mcp"}');
INSERT OR IGNORE INTO edges (id,from_node_id,to_node_id,source,created_at,context) VALUES (60,8,32,'mcp','2026-03-17T01:49:23.184Z','{"type":"related_to","confidence":0.5,"inferred_at":"2026-03-17T01:49:23.184Z","explanation":"was extended with AI recipe engine functions and routes","created_via":"mcp"}');
INSERT OR IGNORE INTO edges (id,from_node_id,to_node_id,source,created_at,context) VALUES (61,8,33,'mcp','2026-03-17T01:49:25.876Z','{"type":"related_to","confidence":0.5,"inferred_at":"2026-03-17T01:49:25.876Z","explanation":"was extended with recipe rating, AI saving, and full extraction routes","created_via":"mcp"}');
INSERT OR IGNORE INTO edges (id,from_node_id,to_node_id,source,created_at,context) VALUES (62,8,34,'mcp','2026-03-17T01:49:28.492Z','{"type":"related_to","confidence":0.5,"inferred_at":"2026-03-17T01:49:28.492Z","explanation":"received major frontend upgrade with recipe panel and variation system","created_via":"mcp"}');
INSERT OR IGNORE INTO edges (id,from_node_id,to_node_id,source,created_at,context) VALUES (63,8,35,'mcp','2026-03-17T01:49:31.386Z','{"type":"related_to","confidence":0.5,"inferred_at":"2026-03-17T01:49:31.386Z","explanation":"received major recipes page upgrade with ratings, filters, and budget integration","created_via":"mcp"}');
INSERT OR IGNORE INTO edges (id,from_node_id,to_node_id,source,created_at,context) VALUES (64,8,36,'mcp','2026-03-17T01:49:37.126Z','{"type":"related_to","confidence":0.5,"inferred_at":"2026-03-17T01:49:37.126Z","explanation":"was extended with budget meal creation from saved recipes","created_via":"mcp"}');
INSERT OR IGNORE INTO edges (id,from_node_id,to_node_id,source,created_at,context) VALUES (65,10,32,'mcp','2026-03-17T01:49:41.234Z','{"type":"related_to","confidence":0.5,"inferred_at":"2026-03-17T01:49:41.234Z","explanation":"provides db_save_recipe and new helpers consumed by the AI recipe engine","created_via":"mcp"}');
INSERT OR IGNORE INTO edges (id,from_node_id,to_node_id,source,created_at,context) VALUES (66,10,33,'mcp','2026-03-17T01:49:44.621Z','{"type":"related_to","confidence":0.5,"inferred_at":"2026-03-17T01:49:44.621Z","explanation":"provides db_rate_recipe and db_update_recipe_tags used by new recipe routes","created_via":"mcp"}');
INSERT OR IGNORE INTO edges (id,from_node_id,to_node_id,source,created_at,context) VALUES (67,32,33,'mcp','2026-03-17T01:49:51.279Z','{"type":"related_to","confidence":0.5,"inferred_at":"2026-03-17T01:49:51.279Z","explanation":"provides get_full_recipe_from_text used by extract-recipe-full route","created_via":"mcp"}');
INSERT OR IGNORE INTO edges (id,from_node_id,to_node_id,source,created_at,context) VALUES (68,34,32,'mcp','2026-03-17T01:49:54.449Z','{"type":"related_to","confidence":0.5,"inferred_at":"2026-03-17T01:49:54.449Z","explanation":"calls /generate-full, /api/recipe/variations, and /api/recipe/substitutions from the AI recipe engine","created_via":"mcp"}');
INSERT OR IGNORE INTO edges (id,from_node_id,to_node_id,source,created_at,context) VALUES (69,34,33,'mcp','2026-03-17T01:49:57.369Z','{"type":"related_to","confidence":0.5,"inferred_at":"2026-03-17T01:49:57.369Z","explanation":"calls /api/recipes/save-ai to persist AI-generated recipes","created_via":"mcp"}');
INSERT OR IGNORE INTO edges (id,from_node_id,to_node_id,source,created_at,context) VALUES (70,35,33,'mcp','2026-03-17T01:50:00.462Z','{"type":"related_to","confidence":0.5,"inferred_at":"2026-03-17T01:50:00.462Z","explanation":"calls /api/recipes/<id>/rate and /api/recipes/<id>/tags","created_via":"mcp"}');
INSERT OR IGNORE INTO edges (id,from_node_id,to_node_id,source,created_at,context) VALUES (71,35,36,'mcp','2026-03-17T01:50:03.843Z','{"type":"related_to","confidence":0.5,"inferred_at":"2026-03-17T01:50:03.843Z","explanation":"calls /api/budget/meal/from-recipe/<id> via the budget day picker dialog","created_via":"mcp"}');
INSERT OR IGNORE INTO edges (id,from_node_id,to_node_id,source,created_at,context) VALUES (72,8,37,'mcp','2026-03-17T02:13:58.897Z','{"type":"related_to","confidence":0.5,"inferred_at":"2026-03-17T02:13:58.897Z","explanation":"extends the recipe flow with end-to-end My Recipes → Price Finder panel restoration","created_via":"mcp"}');
INSERT OR IGNORE INTO edges (id,from_node_id,to_node_id,source,created_at,context) VALUES (73,38,8,'mcp','2026-03-17T02:20:12.294Z','{"type":"related_to","confidence":0.5,"inferred_at":"2026-03-17T02:20:12.294Z","explanation":"is a deferred extension plan for the app documented in","created_via":"mcp"}');
INSERT OR IGNORE INTO edges (id,from_node_id,to_node_id,source,created_at,context) VALUES (74,39,19,'mcp','2026-03-17T02:23:59.141Z','{"type":"related_to","confidence":0.5,"inferred_at":"2026-03-17T02:23:59.141Z","explanation":"is the long-term financial vision that parallels the project vision in","created_via":"mcp"}');
INSERT OR IGNORE INTO edges (id,from_node_id,to_node_id,source,created_at,context) VALUES (75,39,8,'mcp','2026-03-17T02:24:03.461Z','{"type":"related_to","confidence":0.5,"inferred_at":"2026-03-17T02:24:03.461Z","explanation":"represents the near-term financial app extensions that build on top of","created_via":"mcp"}');
INSERT OR IGNORE INTO edges (id,from_node_id,to_node_id,source,created_at,context) VALUES (76,39,6,'mcp','2026-03-17T02:24:07.977Z','{"type":"related_to","confidence":0.5,"inferred_at":"2026-03-17T02:24:07.977Z","explanation":"connects financial wellness goals to the broader personal development hub at","created_via":"mcp"}');
INSERT OR IGNORE INTO edges (id,from_node_id,to_node_id,source,created_at,context) VALUES (77,40,39,'mcp','2026-03-17T02:27:55.884Z','{"type":"related_to","confidence":0.5,"inferred_at":"2026-03-17T02:27:55.884Z","explanation":"is the bank data layer that will eventually power the financial apps described in","created_via":"mcp"}');
INSERT OR IGNORE INTO edges (id,from_node_id,to_node_id,source,created_at,context) VALUES (78,40,8,'mcp','2026-03-17T02:27:58.021Z','{"type":"related_to","confidence":0.5,"inferred_at":"2026-03-17T02:27:58.021Z","explanation":"would automate real transaction data import into the grocery budget app documented in","created_via":"mcp"}');
INSERT OR IGNORE INTO edges (id,from_node_id,to_node_id,source,created_at,context) VALUES (79,41,39,'mcp','2026-03-17T02:39:26.869Z','{"type":"related_to","confidence":0.5,"inferred_at":"2026-03-17T02:39:26.869Z","explanation":"is a specialized mode and extension of the financial app design described in","created_via":"mcp"}');
INSERT OR IGNORE INTO edges (id,from_node_id,to_node_id,source,created_at,context) VALUES (80,41,22,'mcp','2026-03-17T02:39:29.144Z','{"type":"related_to","confidence":0.5,"inferred_at":"2026-03-17T02:39:29.144Z","explanation":"uses stoic philosophy and emotional regulation principles from","created_via":"mcp"}');
INSERT OR IGNORE INTO edges (id,from_node_id,to_node_id,source,created_at,context) VALUES (81,41,6,'mcp','2026-03-17T02:39:32.412Z','{"type":"related_to","confidence":0.5,"inferred_at":"2026-03-17T02:39:32.412Z","explanation":"addresses financial stress as a mental health factor connected to","created_via":"mcp"}');
INSERT OR IGNORE INTO edges (id,from_node_id,to_node_id,source,created_at,context) VALUES (82,41,14,'mcp','2026-03-17T02:39:35.981Z','{"type":"related_to","confidence":0.5,"inferred_at":"2026-03-17T02:39:35.981Z","explanation":"references Stridemon walking as the stress-reset mechanism when financial anxiety spikes in","created_via":"mcp"}');
INSERT OR IGNORE INTO edges (id,from_node_id,to_node_id,source,created_at,context) VALUES (83,42,41,'mcp','2026-03-17T02:50:47.411Z','{"type":"related_to","confidence":0.5,"inferred_at":"2026-03-17T02:50:47.411Z","explanation":"supersedes and expands the earlier gig worker mode design in","created_via":"mcp"}');
INSERT OR IGNORE INTO edges (id,from_node_id,to_node_id,source,created_at,context) VALUES (84,42,39,'mcp','2026-03-17T02:50:49.667Z','{"type":"related_to","confidence":0.5,"inferred_at":"2026-03-17T02:50:49.667Z","explanation":"is the primary financial app project that this design spec builds toward, part of","created_via":"mcp"}');
INSERT OR IGNORE INTO edges (id,from_node_id,to_node_id,source,created_at,context) VALUES (85,42,40,'mcp','2026-03-17T02:50:51.804Z','{"type":"related_to","confidence":0.5,"inferred_at":"2026-03-17T02:50:51.804Z","explanation":"requires Teller bank integration for its auto-import phase, documented in","created_via":"mcp"}');
INSERT OR IGNORE INTO edges (id,from_node_id,to_node_id,source,created_at,context) VALUES (86,42,22,'mcp','2026-03-17T02:50:54.310Z','{"type":"related_to","confidence":0.5,"inferred_at":"2026-03-17T02:50:54.310Z","explanation":"uses stoic philosophy and financial stress management principles from","created_via":"mcp"}');
INSERT OR IGNORE INTO edges (id,from_node_id,to_node_id,source,created_at,context) VALUES (87,42,6,'mcp','2026-03-17T02:51:00.179Z','{"type":"related_to","confidence":0.5,"inferred_at":"2026-03-17T02:51:00.179Z","explanation":"connects financial anxiety reduction to the wellness principles in","created_via":"mcp"}');
INSERT OR IGNORE INTO edges (id,from_node_id,to_node_id,source,created_at,context) VALUES (88,43,42,'mcp','2026-03-17T02:56:16.325Z','{"type":"related_to","confidence":0.5,"inferred_at":"2026-03-17T02:56:16.325Z","explanation":"adds SSI and W-2 income mode specifications that extend the family design in","created_via":"mcp"}');
INSERT OR IGNORE INTO edges (id,from_node_id,to_node_id,source,created_at,context) VALUES (89,43,39,'mcp','2026-03-17T02:56:18.877Z','{"type":"related_to","confidence":0.5,"inferred_at":"2026-03-17T02:56:18.877Z","explanation":"is part of the broader financial freedom app ecosystem planned in","created_via":"mcp"}');
INSERT OR IGNORE INTO edges (id,from_node_id,to_node_id,source,created_at,context) VALUES (90,44,42,'mcp','2026-03-17T02:59:40.319Z','{"type":"related_to","confidence":0.5,"inferred_at":"2026-03-17T02:59:40.319Z","explanation":"is the plain-English pitch that summarizes the full design documented in","created_via":"mcp"}');
INSERT OR IGNORE INTO edges (id,from_node_id,to_node_id,source,created_at,context) VALUES (91,44,43,'mcp','2026-03-17T02:59:42.665Z','{"type":"related_to","confidence":0.5,"inferred_at":"2026-03-17T02:59:42.665Z","explanation":"references the SSI and W-2 income mode details fully documented in","created_via":"mcp"}');

INSERT OR IGNORE INTO dimensions (name,description,icon,is_priority,updated_at) VALUES ('research',NULL,NULL,1,'2026-03-16 10:31:05');
INSERT OR IGNORE INTO dimensions (name,description,icon,is_priority,updated_at) VALUES ('ideas',NULL,NULL,1,'2026-03-16 10:31:05');
INSERT OR IGNORE INTO dimensions (name,description,icon,is_priority,updated_at) VALUES ('projects',NULL,NULL,1,'2026-03-16 10:31:05');
INSERT OR IGNORE INTO dimensions (name,description,icon,is_priority,updated_at) VALUES ('memory',NULL,NULL,1,'2026-03-16 10:31:05');
INSERT OR IGNORE INTO dimensions (name,description,icon,is_priority,updated_at) VALUES ('preferences',NULL,NULL,1,'2026-03-16 10:31:05');
INSERT OR IGNORE INTO dimensions (name,description,icon,is_priority,updated_at) VALUES ('health','Mental and physical wellness, body optimization, mindset, and personal development practices',NULL,1,'2026-03-16 10:35:55');

INSERT OR IGNORE INTO node_dimensions (node_id,dimension) VALUES (1,'memory');
INSERT OR IGNORE INTO node_dimensions (node_id,dimension) VALUES (1,'preferences');
INSERT OR IGNORE INTO node_dimensions (node_id,dimension) VALUES (2,'projects');
INSERT OR IGNORE INTO node_dimensions (node_id,dimension) VALUES (2,'research');
INSERT OR IGNORE INTO node_dimensions (node_id,dimension) VALUES (3,'projects');
INSERT OR IGNORE INTO node_dimensions (node_id,dimension) VALUES (4,'ideas');
INSERT OR IGNORE INTO node_dimensions (node_id,dimension) VALUES (4,'projects');
INSERT OR IGNORE INTO node_dimensions (node_id,dimension) VALUES (5,'research');
INSERT OR IGNORE INTO node_dimensions (node_id,dimension) VALUES (6,'health');
INSERT OR IGNORE INTO node_dimensions (node_id,dimension) VALUES (6,'research');
INSERT OR IGNORE INTO node_dimensions (node_id,dimension) VALUES (8,'projects');
INSERT OR IGNORE INTO node_dimensions (node_id,dimension) VALUES (9,'projects');
INSERT OR IGNORE INTO node_dimensions (node_id,dimension) VALUES (10,'projects');
INSERT OR IGNORE INTO node_dimensions (node_id,dimension) VALUES (11,'projects');
INSERT OR IGNORE INTO node_dimensions (node_id,dimension) VALUES (12,'projects');
INSERT OR IGNORE INTO node_dimensions (node_id,dimension) VALUES (13,'projects');
INSERT OR IGNORE INTO node_dimensions (node_id,dimension) VALUES (14,'projects');
INSERT OR IGNORE INTO node_dimensions (node_id,dimension) VALUES (15,'ideas');
INSERT OR IGNORE INTO node_dimensions (node_id,dimension) VALUES (15,'projects');
INSERT OR IGNORE INTO node_dimensions (node_id,dimension) VALUES (16,'ideas');
INSERT OR IGNORE INTO node_dimensions (node_id,dimension) VALUES (16,'projects');
INSERT OR IGNORE INTO node_dimensions (node_id,dimension) VALUES (17,'projects');
INSERT OR IGNORE INTO node_dimensions (node_id,dimension) VALUES (17,'research');
INSERT OR IGNORE INTO node_dimensions (node_id,dimension) VALUES (18,'projects');
INSERT OR IGNORE INTO node_dimensions (node_id,dimension) VALUES (18,'research');
INSERT OR IGNORE INTO node_dimensions (node_id,dimension) VALUES (19,'ideas');
INSERT OR IGNORE INTO node_dimensions (node_id,dimension) VALUES (19,'projects');
INSERT OR IGNORE INTO node_dimensions (node_id,dimension) VALUES (20,'preferences');
INSERT OR IGNORE INTO node_dimensions (node_id,dimension) VALUES (20,'projects');
INSERT OR IGNORE INTO node_dimensions (node_id,dimension) VALUES (21,'memory');
INSERT OR IGNORE INTO node_dimensions (node_id,dimension) VALUES (21,'projects');
INSERT OR IGNORE INTO node_dimensions (node_id,dimension) VALUES (22,'preferences');
INSERT OR IGNORE INTO node_dimensions (node_id,dimension) VALUES (22,'research');
INSERT OR IGNORE INTO node_dimensions (node_id,dimension) VALUES (23,'preferences');
INSERT OR IGNORE INTO node_dimensions (node_id,dimension) VALUES (23,'research');
INSERT OR IGNORE INTO node_dimensions (node_id,dimension) VALUES (24,'ideas');
INSERT OR IGNORE INTO node_dimensions (node_id,dimension) VALUES (24,'research');
INSERT OR IGNORE INTO node_dimensions (node_id,dimension) VALUES (25,'ideas');
INSERT OR IGNORE INTO node_dimensions (node_id,dimension) VALUES (25,'projects');
INSERT OR IGNORE INTO node_dimensions (node_id,dimension) VALUES (25,'research');
INSERT OR IGNORE INTO node_dimensions (node_id,dimension) VALUES (26,'ideas');
INSERT OR IGNORE INTO node_dimensions (node_id,dimension) VALUES (26,'memory');
INSERT OR IGNORE INTO node_dimensions (node_id,dimension) VALUES (26,'preferences');
INSERT OR IGNORE INTO node_dimensions (node_id,dimension) VALUES (27,'ideas');
INSERT OR IGNORE INTO node_dimensions (node_id,dimension) VALUES (27,'memory');
INSERT OR IGNORE INTO node_dimensions (node_id,dimension) VALUES (28,'ideas');
INSERT OR IGNORE INTO node_dimensions (node_id,dimension) VALUES (28,'memory');
INSERT OR IGNORE INTO node_dimensions (node_id,dimension) VALUES (28,'projects');
INSERT OR IGNORE INTO node_dimensions (node_id,dimension) VALUES (29,'ideas');
INSERT OR IGNORE INTO node_dimensions (node_id,dimension) VALUES (29,'projects');
INSERT OR IGNORE INTO node_dimensions (node_id,dimension) VALUES (30,'preferences');
INSERT OR IGNORE INTO node_dimensions (node_id,dimension) VALUES (31,'ideas');
INSERT OR IGNORE INTO node_dimensions (node_id,dimension) VALUES (31,'memory');
INSERT OR IGNORE INTO node_dimensions (node_id,dimension) VALUES (31,'preferences');
INSERT OR IGNORE INTO node_dimensions (node_id,dimension) VALUES (32,'projects');
INSERT OR IGNORE INTO node_dimensions (node_id,dimension) VALUES (33,'projects');
INSERT OR IGNORE INTO node_dimensions (node_id,dimension) VALUES (34,'projects');
INSERT OR IGNORE INTO node_dimensions (node_id,dimension) VALUES (35,'projects');
INSERT OR IGNORE INTO node_dimensions (node_id,dimension) VALUES (36,'projects');
INSERT OR IGNORE INTO node_dimensions (node_id,dimension) VALUES (37,'projects');
INSERT OR IGNORE INTO node_dimensions (node_id,dimension) VALUES (38,'ideas');
INSERT OR IGNORE INTO node_dimensions (node_id,dimension) VALUES (38,'projects');
INSERT OR IGNORE INTO node_dimensions (node_id,dimension) VALUES (39,'ideas');
INSERT OR IGNORE INTO node_dimensions (node_id,dimension) VALUES (39,'projects');
INSERT OR IGNORE INTO node_dimensions (node_id,dimension) VALUES (40,'ideas');
INSERT OR IGNORE INTO node_dimensions (node_id,dimension) VALUES (40,'projects');
INSERT OR IGNORE INTO node_dimensions (node_id,dimension) VALUES (41,'health');
INSERT OR IGNORE INTO node_dimensions (node_id,dimension) VALUES (41,'ideas');
INSERT OR IGNORE INTO node_dimensions (node_id,dimension) VALUES (41,'projects');
INSERT OR IGNORE INTO node_dimensions (node_id,dimension) VALUES (42,'health');
INSERT OR IGNORE INTO node_dimensions (node_id,dimension) VALUES (42,'ideas');
INSERT OR IGNORE INTO node_dimensions (node_id,dimension) VALUES (42,'memory');
INSERT OR IGNORE INTO node_dimensions (node_id,dimension) VALUES (42,'projects');
INSERT OR IGNORE INTO node_dimensions (node_id,dimension) VALUES (43,'ideas');
INSERT OR IGNORE INTO node_dimensions (node_id,dimension) VALUES (43,'memory');
INSERT OR IGNORE INTO node_dimensions (node_id,dimension) VALUES (43,'projects');
INSERT OR IGNORE INTO node_dimensions (node_id,dimension) VALUES (44,'memory');
INSERT OR IGNORE INTO node_dimensions (node_id,dimension) VALUES (44,'projects');
INSERT OR IGNORE INTO node_dimensions (node_id,dimension) VALUES (45,'memory');
INSERT OR IGNORE INTO node_dimensions (node_id,dimension) VALUES (45,'projects');
INSERT OR IGNORE INTO node_dimensions (node_id,dimension) VALUES (46,'memory');
INSERT OR IGNORE INTO node_dimensions (node_id,dimension) VALUES (46,'projects');


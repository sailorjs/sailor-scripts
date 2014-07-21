
//   |>   [a Sails app]
// \___/  For help, see: http://links.sailsjs.org/docs

// Tip: Use `sails.config` to access your app's runtime configuration.

// 1 Models:
// User

// 0 Controllers:


// 20 Hooks:
// moduleloader,logger,request,orm,views,blueprints,responses,controllers,sockets,pubsub,policies,services,csrf,cors,i18n,userconfig,session,grunt,http,userhooks


{ blueprints:
   { actions: true,
     rest: true,
     shortcuts: true,
     prefix: '',
     pluralize: false,
     populate: true,
     index: true,
     autoWatch: true },
  bootstrap: [Function],
  connections:
   { localDiskDb: { adapter: 'sails-disk' },
     someMysqlServer:
      { adapter: 'sails-mysql',
        host: 'YOUR_MYSQL_SERVER_HOSTNAME_OR_IP_ADDRESS',
        user: 'YOUR_MYSQL_USER',
        password: 'YOUR_MYSQL_PASSWORD',
        database: 'YOUR_MYSQL_DB' },
     someMongodbServer: { adapter: 'sails-mongo', host: 'localhost', port: 27017 },
     somePostgresqlServer:
      { adapter: 'sails-postgresql',
        host: 'YOUR_POSTGRES_SERVER_HOSTNAME_OR_IP_ADDRESS',
        user: 'YOUR_POSTGRES_USER',
        password: 'YOUR_POSTGRES_PASSWORD',
        database: 'YOUR_POSTGRES_DB' } },
  cors:
   { allRoutes: false,
     origin: '*',
     credentials: true,
     methods: 'GET, POST, PUT, DELETE, OPTIONS, HEAD',
     headers: 'content-type' },
  csrf:
   { grantTokenViaAjax: false,
     protectionEnabled: false,
     origin: '' },
  globals:
   { _: true,
     async: true,
     sails: true,
     services: true,
     models: true,
     adapters: true },
  http:
   { middleware: { order: [Object] },
     cache: 31557600000,
     serverOptions: undefined,
     customMiddleware: undefined,
     bodyParser: undefined,
     cookieParser: [Function: cookieParser],
     methodOverride: [Function: methodOverride] },
  i18n:
   { locales: [ 'en', 'es', 'fr', 'de' ],
     defaultLocale: 'en',
     localesDirectory: '/config/locales' },
  port: 1342,
  environment: 'development',
  log: { level: 'info' },
  models: { connection: 'localDiskDb' },
  policies: { '*': true },
  routes: { '/': { view: 'homepage' } },
  session:
   { secret: 'f6b159965b096d63e39e18f06da740a2',
     adapter: 'memory',
     key: 'sails.sid' },
  sockets:
   { onConnect: [Function],
     onDisconnect: [Function],
     transports: [ 'websocket', 'htmlfile', 'xhr-polling', 'jsonp-polling' ],
     adapter: 'memory',
     authorization: false,
     'backwardsCompatibilityFor0.9SocketClients': false,
     grant3rdPartyCookie: true,
     origins: '*:*',
     heartbeats: true,
     'close timeout': 60,
     'heartbeat timeout': 60,
     'heartbeat interval': 25,
     'polling duration': 20,
     'flash policy port': 10843,
     'destroy buffer size': '10E7',
     'destroy upgrade': true,
     'browser client': true,
     'browser client cache': true,
     'browser client minification': false,
     'browser client etag': false,
     'browser client expires': 315360000,
     'browser client gzip': false,
     'browser client handler': false,
     'match origin protocol': false,
     store: undefined,
     logger: undefined,
     'log level': undefined,
     'log colors': undefined,
     static: undefined,
     resource: '/socket.io',
     sendResponseHeaders: true,
     sendStatusCode: true,
     'flash policy server': false },
  views: { engine: { ext: 'ejs', fn: [Object] }, layout: 'layout' },
  hooks:
   { moduleloader: [Function],
     logger: [Function],
     request: [Function],
     orm: [Function],
     views: [Function],
     blueprints: [Function],
     responses: [Function],
     controllers: [Function],
     sockets: [Function],
     pubsub: [Function],
     policies: [Function],
     services: [Function],
     csrf: [Function],
     cors: [Function],
     i18n: [Function],
     userconfig: [Function],
     session: [Function],
     grunt: [Function],
     http: [Function],
     userhooks: [Function] },
  appPath: '/YOUR_PATH/testApp',
  paths:
   { tmp: '/YOUR_PATH/testApp/.tmp',
     config: '/YOUR_PATH/testApp/config',
     controllers: '/YOUR_PATH/testApp/api/controllers',
     policies: '/YOUR_PATH/testApp/api/policies',
     services: '/YOUR_PATH/testApp/api/services',
     adapters: '/YOUR_PATH/testApp/api/adapters',
     models: '/YOUR_PATH/testApp/api/models',
     hooks: '/YOUR_PATH/testApp/api/hooks',
     blueprints: '/YOUR_PATH/testApp/api/blueprints',
     responses: '/YOUR_PATH/testApp/api/responses',
     views: '/YOUR_PATH/testApp/views',
     layout: '/YOUR_PATH/testApp/views/layout.ejs',
     public: '/YOUR_PATH/testApp/.tmp/public' },
  middleware: {},
  ssl: {},
  cache: { maxAge: 1 } }

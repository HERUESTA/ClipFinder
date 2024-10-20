// This file is auto-generated by ./bin/rails stimulus:manifest:update
// Run that command whenever you add a new controller or create them with
// ./bin/rails generate stimulus controllerName

import { application } from "./application"

import ClipLoaderController from "./clip_loader_controller"
application.register("clip-loader", ClipLoaderController)

import HelloController from "./hello_controller"
application.register("hello", HelloController)

import PaginationScrollController from "./pagination_scroll_controller"
application.register("pagination-scroll", PaginationScrollController)

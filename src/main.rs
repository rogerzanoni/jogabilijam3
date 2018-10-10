extern crate ggez;

use entities::*;
use ggez::conf::*;
use ggez::graphics::Point2;
use ggez::*;

mod entities;
mod utils;

struct MainState {
    officers: Vec<Officer>,
    demonstrators: Vec<Demonstrator>,
}

impl MainState {
    fn new(ctx: &mut Context) -> GameResult<MainState> {
        let s = MainState {
            officers: MainState::create_officers(ctx),
            demonstrators: MainState::create_demonstrators(ctx),
        };
        Ok(s)
    }

    fn create_officers(ctx: &mut Context) -> Vec<Officer> {
        let mut vec = Vec::new();
        vec.push(Officer::build_officer(ctx, Point2::new(120.0, 200.0)));
        vec.push(Officer::build_officer(ctx, Point2::new(120.0, 250.0)));
        vec.push(Officer::build_officer(ctx, Point2::new(120.0, 300.0)));
        vec
    }

    fn create_demonstrators(ctx: &mut Context) -> Vec<Demonstrator> {
        let mut vec = Vec::new();
        vec.push(Demonstrator::build_demonstrator(
            ctx,
            Point2::new(400.0, 225.0),
        ));
        vec.push(Demonstrator::build_demonstrator(
            ctx,
            Point2::new(400.0, 275.0),
        ));
        vec
    }
}

impl event::EventHandler for MainState {
    fn update(&mut self, _ctx: &mut Context) -> GameResult<()> {
        for ref mut officer in &mut self.officers {
            officer.update(&self.demonstrators);
        }

        for ref mut demonstrator in &mut self.demonstrators {
            demonstrator.update(&self.officers);
        }
        Ok(())
    }

    fn draw(&mut self, ctx: &mut Context) -> GameResult<()> {
        graphics::clear(ctx);

        for demonstrator in &self.demonstrators {
            demonstrator.draw(ctx);
        }

        for officer in &self.officers {
            officer.draw(ctx);
        }

        graphics::present(ctx);

        Ok(())
    }
}

pub fn main() {
    let conf = Conf {
        window_mode: WindowMode {
            width: 1280,
            height: 720,
            borderless: false,
            fullscreen_type: FullscreenType::Desktop,
            vsync: true,
            min_width: 0,
            max_width: 0,
            min_height: 0,
            max_height: 0,
        },
        window_setup: WindowSetup::default(),
        backend: Backend::OpenGL { major: 3, minor: 2 },
    };
    let ctx = &mut Context::load_from_conf("Jogabilijam 3", "Largato Games", conf).unwrap();
    let state = &mut MainState::new(ctx).unwrap();
    event::run(ctx, state).unwrap();
}

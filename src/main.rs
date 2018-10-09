extern crate ggez;

use entities::*;
use ggez::conf::*;
use ggez::graphics::{Color, DrawMode, Point2};
use ggez::*;

mod entities;
mod utils;

struct MainState {
    officers: Vec<Officer>,
    demonstrators: Vec<Demonstrator>,
}

impl MainState {
    fn new(_ctx: &mut Context) -> GameResult<MainState> {
        let s = MainState {
            officers: MainState::create_officers(),
            demonstrators: MainState::create_demonstrators(),
        };
        Ok(s)
    }

    fn create_officers() -> Vec<Officer> {
        let mut vec = Vec::new();

        vec.push(Officer {
            position: Point2::new(120.0, 200.0),
            velocity: Point2::new(0.2, 0.2),
            max_velocity: 0.5,
            color: Color::from_rgb(0, 0, 255),
            size: Point2::new(10.0, 10.0),
        });

        vec.push(Officer {
            position: Point2::new(120.0, 250.0),
            velocity: Point2::new(0.2, 0.2),
            max_velocity: 0.5,
            color: Color::from_rgb(0, 0, 255),
            size: Point2::new(10.0, 10.0),
        });

        vec.push(Officer {
            position: Point2::new(120.0, 300.0),
            velocity: Point2::new(0.2, 0.2),
            max_velocity: 0.5,
            color: Color::from_rgb(0, 0, 255),
            size: Point2::new(10.0, 10.0),
        });

        vec
    }

    fn create_demonstrators() -> Vec<Demonstrator> {
        let mut vec = Vec::new();

        vec.push(Demonstrator {
            position: Point2::new(400.0, 225.0),
            velocity: Point2::new(0.2, 0.2),
            max_velocity: 0.7,
            size: Point2::new(10.0, 10.0),
            color: Color::from_rgb(255, 0, 0),
        });

        vec.push(Demonstrator {
            position: Point2::new(400.0, 275.0),
            velocity: Point2::new(0.2, 0.2),
            max_velocity: 0.7,
            size: Point2::new(10.0, 10.0),
            color: Color::from_rgb(255, 0, 0),
        });

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
            graphics::set_color(ctx, demonstrator.color);
            graphics::circle(ctx, DrawMode::Fill, demonstrator.position, 10.0, 0.2);
        }

        for officer in &self.officers {
            graphics::set_color(ctx, officer.color);
            graphics::circle(ctx, DrawMode::Fill, officer.position, 10.0, 0.2)?;
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

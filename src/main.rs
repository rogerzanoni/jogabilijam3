extern crate ggez;

use ggez::conf::*;
use ggez::graphics::{Color, DrawMode, Point2};
use ggez::*;

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
            position: Point2::new(120.0, 400.0),
            velocity: Point2::new(0.2, 0.2),
            max_velocity: 0.5,
            color: Color::from_rgb(0, 0, 255),
        });

        vec.push(Officer {
            position: Point2::new(420.0, 180.0),
            velocity: Point2::new(0.2, 0.2),
            max_velocity: 0.5,
            color: Color::from_rgb(0, 0, 255),
        });

        vec.push(Officer {
            position: Point2::new(600.0, 400.0),
            velocity: Point2::new(0.2, 0.2),
            max_velocity: 0.5,
            color: Color::from_rgb(0, 0, 255),
        });

        vec
    }

    fn create_demonstrators() -> Vec<Demonstrator> {
        let mut vec = Vec::new();

        vec.push(Demonstrator {
            position: Point2::new(400.0, 400.0),
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

struct Officer {
    position: Point2,
    velocity: Point2,
    max_velocity: f32,
    color: Color,
}

impl Officer {
    fn update(&mut self, targets: &Vec<Demonstrator>) {
        let target = &targets[0];

        // Seek behaviour
        let desired_velocity =
            normalize_vector(sub_vectors(target.position, self.position)) * self.max_velocity;
        let steering = desired_velocity - self.velocity;
        self.velocity = self.velocity + steering;

        // Update position
        self.position = sum_vectors(self.position, self.velocity);
    }
}

struct Demonstrator {
    position: Point2,
    velocity: Point2,
    max_velocity: f32,
    size: Point2,
    color: Color,
}

impl Demonstrator {
    fn update(&mut self, officers: &Vec<Officer>) {
        let mut closest = &officers[0];
        let closest_distance = distance(self.position, closest.position);

        for officer in officers {
            let distance = distance(self.position, officer.position);
            if distance < closest_distance {
                closest = officer;
            }
        }

        // Seek behaviour
        let desired_velocity =
            normalize_vector(sub_vectors(self.position, closest.position)) * self.max_velocity;
        let steering = desired_velocity - self.velocity;
        self.velocity = self.velocity + steering;

        // Update position
        self.position = sum_vectors(self.position, self.velocity);
        self.position = truncate_vector(
            self.position,
            Point2::new(0.0, 0.0),
            Point2::new(800.0 - self.size.x / 2.0, 600.0 - self.size.y / 2.0),
        );
    }
}

fn truncate_vector(p: Point2, min: Point2, max: Point2) -> Point2 {
    let mut trunc = p.clone();

    if trunc.x < 0.0 {
        trunc.x = 0.0;
    } else if trunc.x > max.x {
        trunc.x = max.x;
    }

    if trunc.y < 0.0 {
        trunc.y = 0.0;
    } else if trunc.y > max.y {
        trunc.y = max.y;
    }
    trunc
}

fn sum_vectors(p1: Point2, p2: Point2) -> Point2 {
    Point2::new(p1.x + p2.x, p1.y + p2.y)
}

fn sub_vectors(p1: Point2, p2: Point2) -> Point2 {
    Point2::new(p1.x - p2.x, p1.y - p2.y)
}

fn normalize_vector(p: Point2) -> Point2 {
    let module = (p.x.powi(2) + p.y.powi(2)).sqrt();
    Point2::new(p.x / module, p.y / module)
}

fn distance(p1: Point2, p2: Point2) -> f32 {
    ((p1.x - p2.x).powi(2) + (p1.y - p2.y).powi(2)).sqrt()
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

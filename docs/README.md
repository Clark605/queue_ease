# Queue Ease - Documentation Index

Welcome to the Queue Ease documentation hub. This folder contains all technical and product documentation for the project.

---

## 📚 Documentation Overview

### Core Documents

#### [Constitution (.specify/memory/constitution.md)](../.specify/memory/constitution.md)
**Project governance: Core principles and development standards**

- 6 Core Principles: Code Quality First, Flexibility & Extensibility, Pragmatic Testing, UX Consistency, Fast Delivery, Performance Requirements
- Technical Standards: Flutter/Dart requirements, Result<T> error handling pattern, AppException hierarchy
- Domain-Specific Rules: 5 core business entities, time margin policy for no-shows, MVP scope constraints
- Security & Compliance: Firestore security rules, RBAC enforcement, PII protection
- Development Workflow: Code review gates, quality checks, branching strategy (main/develop/feature)
- Amendment process and governance enforcement

**When to use**: Before starting ANY new work to verify compliance with project principles. Reference during code reviews to ensure architecture alignment. Consult when making major technical decisions.

---

#### [ARCHITECTURE.md](ARCHITECTURE.md)
**Comprehensive technical architecture documentation**

- Clean Architecture implementation details
- Project structure and folder organization
- Layer responsibilities (Presentation, Domain, Data)
- Feature module organization
- Dependency injection setup (GetIt + Injectable)
- Error handling framework (Result type, AppException hierarchy)
- Navigation architecture (GoRouter with RBAC)
- State management (flutter_bloc Cubit pattern)
- Testing strategy and guidelines
- Code organization standards
- Firestore data structure
- Environment configuration (Dev/Prod flavors)

**When to use**: Reference this when implementing new features, understanding architectural decisions, or onboarding new developers.

---

#### [domain/PRD.md](domain/PRD.md)
**Product Requirements Document**

- Product vision and goals
- Problem statement
- Target users (Admin & Customer)
- MVP scope and features
- User stories and workflows
- Success metrics
- Out-of-scope features

**When to use**: Understanding product requirements, feature priorities, and business goals.

---

#### [domain/ENTITIES.md](domain/ENTITIES.md)
**Domain Entity Models Specification**

- Complete domain entity definitions
- Firestore data model mappings
- Field specifications and types
- Firestore collection paths
- Testing requirements for entities/models
- Deferred entities (future phases)

**Entities Defined**:
1. `OrganizationEntity` - Business profile
2. `ServiceEntity` - Bookable services
3. `WorkingHoursEntity` - Daily schedules
4. `AppointmentEntity` - Customer bookings
5. `QueueEntity` - Daily queue management

**When to use**: Implementing data models, writing tests, or understanding domain structure.

---

#### [FEATURE_CHECKLIST.md](FEATURE_CHECKLIST.md)
**Feature Implementation Tracking**

- Comprehensive feature checklist organized by category
- Implementation status (✅ Complete, 🚧 In Progress, ⏳ Pending)
- Testing coverage tracking
- MVP completion criteria
- Current progress summary (~75% complete; Sprint 6A active)
- Priority order for development
- Phase breakdown with weekly estimates

**Categories**:
- Core Infrastructure & Setup
- Authentication & User Management
- Onboarding Flow
- Admin Features
- Customer Features
- Core Business Logic
- Real-Time Features
- Notifications
- Data Models & Entities
- Testing
- UI/UX Polish
- DevOps & Deployment
- Documentation

**When to use**: Tracking progress, planning sprints, understanding what's implemented vs. pending.

---

#### [PROJECT_TIMELINE.md](PROJECT_TIMELINE.md)
**Detailed Timeline & Network Diagrams**

- Updated Gantt chart (~4-6 weeks remaining for MVP)
- Phase breakdown with dates
- Dependency network diagrams (Mermaid)
- Critical path analysis
- Weekly work packages
- Milestone definitions
- Risk assessment

**Phases**:
- ✅ Phase 1: Foundation (COMPLETE)
- ✅ Phase 2: Repository Layer & Security (COMPLETE)
- ✅ Phase 3: Admin Core (COMPLETE)
- ✅ Phase 4: Customer Core (COMPLETE)
- ✅ Phase 5: Queue System (COMPLETE)
- Phase 6: Business Logic
- Phase 7: Notifications & Polish
- Phase 8: Testing & Deployment

**When to use**: Project planning, estimating delivery dates, identifying blockers.

---

## 📁 Additional Resources

### `/ui-screens/`
Design mockups and wireframes for all major screens.

### `/demos/`
Video demonstrations and GIFs showcasing implemented features.

---

## � Quick Links

### Repository
- **GitHub**: [Clark605/queue_ease](https://github.com/Clark605/queue_ease)
- **Current Branch**: develop
- **Default Branch**: develop

### Project Status
- **Progress**: See [PROJECT_TIMELINE.md](PROJECT_TIMELINE.md) for current sprint and progress
- **Feature Status**: See [FEATURE_CHECKLIST.md](FEATURE_CHECKLIST.md) for implementation details
- **Next Steps**: See [PROJECT_TIMELINE.md](PROJECT_TIMELINE.md) for Sprint 6A priorities

### Firebase Console
- **Project**: queue-ease (Dev & Prod environments)

### External References
- [Clean Architecture by Uncle Bob](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [flutter_bloc Documentation](https://bloclibrary.dev/)
- [GetIt Documentation](https://pub.dev/packages/get_it)
- [GoRouter Documentation](https://pub.dev/packages/go_router)

---

## 🎯 Getting Started Guide

### For New Developers
1. **Start with** [Constitution (../.specify/memory/constitution.md)](../.specify/memory/constitution.md) - Project governance and principles (MUST READ)
2. **Then read** [ARCHITECTURE.md](ARCHITECTURE.md) - Understand the technical architecture
3. **Review** [domain/PRD.md](domain/PRD.md) - Understand the product and user needs
4. **Check** [domain/ENTITIES.md](domain/ENTITIES.md) - Understand the domain model
5. **See status** [FEATURE_CHECKLIST.md](FEATURE_CHECKLIST.md) - What's already implemented

### For .specify Agent Development
- **Primary Context and Governance**: `../.specify/memory/constitution.md` - Complete project context, structure, and standards. All development must align with 6 core principles
- **Templates**: `../.specify/templates/` - Use spec, plan, and task templates for new features

### For Feature Implementation
1. **Check requirements** in [domain/PRD.md](domain/PRD.md)
2. **Verify compliance** with [Constitution](../.specify/memory/constitution.md)
3. **Follow patterns** in [ARCHITECTURE.md](ARCHITECTURE.md)
4. **Reference domain models** in [domain/ENTITIES.md](domain/ENTITIES.md)
5. **Update status** in [FEATURE_CHECKLIST.md](FEATURE_CHECKLIST.md) when complete

---

## 📝 Documentation Conventions

### Status Indicators
- ✅ **Completed** - Feature fully implemented and tested
- 🚧 **In Progress** - Currently being developed
- ⏳ **Pending** - Not started yet
- 📋 **Planned** - Post-MVP / Future enhancement

### Update Process
- Review and update docs after each major feature
- Keep [FEATURE_CHECKLIST.md](FEATURE_CHECKLIST.md) current (weekly)
- Update [PROJECT_TIMELINE.md](PROJECT_TIMELINE.md) when schedule changes
- Monthly comprehensive documentation review

---

**Document Maintained By**: Development Team  
**Last Updated**: May 21, 2026  
**Version**: 1.3.0+1

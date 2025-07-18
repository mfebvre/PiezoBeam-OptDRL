classdef Env_Passive_crtl_freq_time < rl.env.MATLABEnvironment
    %MYENVIRONMENT: Template for defining custom environment in MATLAB.    
    
    %% Properties (set properties' attributes accordingly)
    properties
        % Specify and initialize environment's necessary properties    
        Figure
        %% State Space
        Sys_rs
       
        % Sample time
        Ts 
        
        q

        w10
        
        action_R_opt
        action_C_opt 
        action_L_opt
        
        time

        Tf
        index_time
        
        input_signal
        
        q10_plot

        w10_plot

        noise
        
        q0

        w10_0

        RewardForNotFalling
        PenaltyForFalling 
        Threshold
    end
    
    properties
        % Initialize system state [q0 w0]'
        State = zeros(2,1)
         
    end

    properties (Transient,Access = private)
        Visualizer = []
    end

    properties(Access = protected)
        % Initialize internal flag to indicate episode termination
        IsDone = false        
    end
%     methods (Abstract,Access = protected)
%         Rvalue = getRvalue(this,action)
%         
%         Reward = getReward(this,x,force)
%     end 

    %% Necessary Methods
    methods             

        % Contructor method creates an instance of the environment
        % Change class name and constructor name accordingly
        function this = Env_Passive_crtl_freq_time(input_Sys_rs,input_Ts,input_Tf,Obsinfo, Actinfo,noise,time)
                      
            % Initialize Observation settings
            ObservationInfo = Obsinfo;
            % Initialize Action settings   
            ActionInfo = Actinfo;
            
            % The following line implements built-in functions of RL env
            this = this@rl.env.MATLABEnvironment(ObservationInfo,ActionInfo)
            
            % Initialize property values and pre-compute necessary values
            %updateActionInfo(this);

            this.Sys_rs=input_Sys_rs;
            this.Ts=input_Ts;
            this.Tf=input_Tf;
            this.noise=noise;
            this.time=time;

            this.RewardForNotFalling = 1;
            this.PenaltyForFalling = -50;
            disp('init')
            
        end
        
        % Apply system dynamics and simulates the environment with the 
        % given action for one step.
        function [Observation,Reward,IsDone,LoggedSignals] = step(this,Action)
            LoggedSignals = [];

                        % Get action
            Action
            
            this.action_R_opt = Action(1);            
            this.action_C_opt = 0;%Action(2); 
            this.action_L_opt = 0;%Action(3);  
          
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            s = tf([1 0],[0 1]);

            Z = 10^(this.action_R_opt);
            Controle =s^2*10^this.action_L_opt+s*Z-1/10^this.action_C_opt;
            Sys_rs_contr = feedback(this.Sys_rs,Controle,1,1);
            
            this.w10=lsim(Sys_rs_contr(end-1,2),this.noise(1:this.index_time),this.time(1:this.index_time));
            this.q=lsim(Sys_rs_contr(1,2),this.noise(1:this.index_time),this.time(1:this.index_time));
            
            %this.w10=lsim(Sys_rs_contr,this.noise(1:this.index_time),this.time(1:this.index_time));
            %this.q=lsim(Sys_rs_contr,this.noise(1:this.index_time),this.time(1:this.index_time));
          

            Observation = [this.State(1); this.State(2)];%rms(this.q)*1e3;
            %Observation(2) = this.State(2);%rms(this.w10)*1e3;
                                   
            Reward=getReward(this) ;           
            
%             
            this.State = Observation;
            
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            IsDone = this.time(this.index_time) > this.Tf || rms(this.q) > this.Threshold;
            this.IsDone = IsDone;

            this.index_time=this.index_time+this.index_time;
            
                       
            % (optional) use notifyEnvUpdated to signal that the 
            % environment has been updated (e.g. to update visualization)
            %varargout = plot(this);
        end
        
        % Reset environment to initial state and output initial observation
        function InitialObservation = reset(this)
            
            this.w10_0=lsim(this.Sys_rs(end-1,2),this.noise,this.time);
            this.q0=lsim(this.Sys_rs(1,2),this.noise,this.time);
            
            %this.w10_0=lsim(this.Sys_rs,this.noise,this.time);
            %this.q0=lsim(this.Sys_rs,this.noise,this.time);

            InitialObservation = [rms(this.q0 ); rms(this.w10_0)]*1e3;
            this.State = InitialObservation;
            this.Threshold=rms(this.q0);
            this.index_time=length(this.time);%round(length(this.time)/10);
            
            this.IsDone=false;

            % (optional) use notifyEnvUpdated to signal that the 
            % environment has been updated (e.g. to update visualization)
            %notifyEnvUpdated(this);
        end

        function varargout = plot(this)
            % Visualizes the environment
            if isempty(this.Visualizer) || ~isvalid(this.Visualizer)
                this.Visualizer = Beam_Visualizer_v2(this);
            else
                bringToFront(this.Visualizer);
            end
            if nargout
                varargout{1} = this.Visualizer;
            end
           
        end
        
    end

    

    %% Optional Methods (set methods' attributes accordingly)
    methods               
        % Helper methods to create the environment
                
                
        % (optional) Visualization method
                  
        function set.Ts(this,val)
            validateattributes(val,{'numeric'},{'finite','real','positive','scalar'},'','Ts');
            this.Ts = val;
        end
        function Reward = getReward(this)
            
            distReward = 20*log10(rms(this.w10_0)/rms(this.w10))
            if isnan(distReward) || (abs(distReward) > 1e10)
                 distReward = 0
            end
            
%             if ~this.IsDone
%                 Reward = 0.5 * this.RewardForNotFalling + 0.5 * distReward*this.time(this.index_time)/this.Tf
%             else
%                 Reward = this.PenaltyForFalling;
%             end 
            Reward=distReward;
        end
    end
   
end
